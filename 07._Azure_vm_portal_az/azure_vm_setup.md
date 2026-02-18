# Azure VM Setup Guide for CI/CD Deployment

This guide covers how to set up an Azure Virtual Machine for deploying your application via the CI/CD pipeline.

## Overview

The Azure VM will serve as your deployment target where:
- Docker containers are pulled from GitHub Container Registry (GHCR)
- The application runs in production
- GitHub Actions connects via SSH to deploy updates

---

## Prerequisites

- Azure account with active subscription
- SSH key pair generated (see [GITHUB_SECRETS_SETUP.md](GITHUB_SECRETS_SETUP.md))
- Basic understanding of Linux command line

---

## Part 1: Creating the Azure VM

### Method 1: Using Azure Portal (Graphical)

#### Step 1: Create Virtual Machine

1. Login to [Azure Portal](https://portal.azure.com)
2. Click **Create a resource** → **Virtual Machine**
3. Configure **Basics** tab:

**Project details:**
- **Subscription:** Select your subscription
- **Resource group:** Create new or select existing (e.g., `recipe-cookbook-rg`)

**Instance details:**
- **Virtual machine name:** `recipe-cookbook-vm` (or your choice)
- **Region:** Choose closest to you (e.g., `East US`, `West Europe`)
- **Availability options:** No infrastructure redundancy required
- **Security type:** Standard
- **Image:** `Ubuntu Server 22.04 LTS - x64 Gen2`
- **Size:** `Standard_B1s` (1 vCPU, 1 GB RAM) - sufficient for demo
  - Click "See all sizes" if not visible
  - For better performance, use `Standard_B2s` (2 vCPUs, 4 GB RAM)

**Administrator account:**
- **Authentication type:** SSH public key
- **Username:** `azureuser` (or your choice - remember for secrets!)
- **SSH public key source:** Use existing public key
- **SSH public key:** Paste your public key
  ```bash
  cat ~/.ssh/id_rsa.pub
  ```

**Inbound port rules:**
- **Public inbound ports:** Allow selected ports
- **Select inbound ports:**
  - ✅ SSH (22)
  - ✅ HTTP (80)
  - ✅ HTTPS (443)

#### Step 2: Configure Disks (Optional)

- **OS disk type:** Standard SSD (sufficient for demo)
- Leave other settings as default

#### Step 3: Configure Networking

- **Virtual network:** Create new or use default
- **Subnet:** Default
- **Public IP:** Create new (note: this is your `SSH_HOST`)
- **NIC network security group:** Basic
- **Public inbound ports:** SSH (22), HTTP (80), HTTPS (443)

**⚠️ Important:** Add custom port for your application:
1. After VM is created, go to **Networking** settings
2. Click **Add inbound port rule**
3. Configure:
   - **Destination port ranges:** `5001`
   - **Protocol:** TCP
   - **Name:** `Allow-Flask-5001`
   - **Priority:** 310
   - Click **Add**

#### Step 4: Review + Create

1. Click **Review + create**
2. Wait for validation
3. Click **Create**
4. Wait 2-5 minutes for deployment

#### Step 5: Get VM Public IP

1. Go to your VM in Azure Portal
2. **Overview** tab → Note the **Public IP address**
3. This is your `SSH_HOST` secret value

---

### Method 2: Using Azure CLI (Faster)

```bash
# Login to Azure
az login

# Create resource group
az group create \
  --name recipe-cookbook-rg \
  --location eastus

# Create VM
az vm create \
  --resource-group recipe-cookbook-rg \
  --name recipe-cookbook-vm \
  --image Ubuntu2204 \
  --size Standard_B1s \
  --admin-username azureuser \
  --ssh-key-values ~/.ssh/id_rsa.pub \
  --public-ip-sku Standard

# Open ports for HTTP, HTTPS, and Flask app
az vm open-port \
  --resource-group recipe-cookbook-rg \
  --name recipe-cookbook-vm \
  --port 80 \
  --priority 300

az vm open-port \
  --resource-group recipe-cookbook-rg \
  --name recipe-cookbook-vm \
  --port 443 \
  --priority 310

az vm open-port \
  --resource-group recipe-cookbook-rg \
  --name recipe-cookbook-vm \
  --port 5001 \
  --priority 320

# Get public IP address
az vm show \
  --resource-group recipe-cookbook-rg \
  --name recipe-cookbook-vm \
  --show-details \
  --query publicIps \
  --output tsv
```

Save the public IP - this is your `SSH_HOST` value.

---

## Part 2: Configuring the VM for Docker

### Step 1: Connect to Your VM

```bash
ssh azureuser@YOUR_VM_PUBLIC_IP
```

Replace `YOUR_VM_PUBLIC_IP` with the IP from Azure Portal or CLI output.

### Step 2: Update System Packages

```bash
sudo apt update && sudo apt upgrade -y
```

### Step 3: Install Docker

```bash
# Install required packages
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index
sudo apt update

# Install Docker (includes Docker Compose plugin)
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Verify Docker installation
sudo docker --version

# Verify Docker Compose plugin installation
sudo docker compose version
```

**Note:** Modern Docker uses `docker compose` (with a space) as a plugin, not the legacy `docker-compose` (with a hyphen).

### Step 4: Configure Docker Permissions

**⚠️ Critical for CI/CD:** Allow your user to run Docker without sudo:

```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Apply group changes
newgrp docker

# Verify (should work without sudo)
docker ps
docker compose version
```

**Alternative (if above doesn't work immediately):**
```bash
# Logout and login again
exit
ssh azureuser@YOUR_VM_PUBLIC_IP

# Test
docker ps
docker compose version
```

### Step 5: Configure GitHub Container Registry Access

Your VM needs to authenticate with GHCR to pull private images:

```bash
# Login to GHCR (you'll be prompted for password - use your CR_PAT token)
docker login ghcr.io -u YOUR_GITHUB_USERNAME

# Enter your CR_PAT token when prompted for password
```

**For automation (optional):**
```bash
echo "YOUR_CR_PAT" | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin
```

### Step 6: Create Working Directory

```bash
# Create directory for deployment files
mkdir -p ~/app
cd ~/app

# Files will be deployed here by CI/CD:
# - docker-compose.yml
# - .env
```

---

## Part 3: Testing the Setup

### Test 1: Verify Docker Works

```bash
docker run hello-world
```

Expected: Success message from Docker.

### Test 2: Verify Docker Compose Works

```bash
docker compose version
```

Expected: Version number displayed (e.g., `Docker Compose version v2.x.x`).

### Test 3: Test GHCR Access

```bash
# Try pulling a public image from GHCR
docker pull ghcr.io/linuxserver/nginx:latest
```

Expected: Image downloaded successfully.

### Test 4: Verify Ports are Open

From your local machine:

```bash
# Test SSH
ssh azureuser@YOUR_VM_PUBLIC_IP "echo 'Connection successful'"

# Test if port 5001 is reachable (will fail until app is deployed)
nc -zv YOUR_VM_PUBLIC_IP 5001
```

---

## Part 4: Security Configuration (Important!)

### Configure Firewall (UFW)

```bash
# Enable UFW
sudo ufw enable

# Allow SSH (CRITICAL - don't lock yourself out!)
sudo ufw allow 22/tcp

# Allow HTTP/HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Allow your application port
sudo ufw allow 5001/tcp

# Check status
sudo ufw status
```

### Secure SSH Access (Recommended)

Edit SSH configuration:
```bash
sudo nano /etc/ssh/sshd_config
```

Recommended changes:
```
# Disable password authentication (key-only)
PasswordAuthentication no

# Disable root login
PermitRootLogin no

# Change default SSH port (optional, requires updating Azure NSG)
# Port 2222
```

Restart SSH:
```bash
sudo systemctl restart sshd
```

---

## Part 5: Verification Checklist

Before running your CI/CD pipeline, verify:

- [ ] VM is running and accessible via SSH
- [ ] Docker is installed and running
- [ ] Docker Compose plugin is installed (`docker compose version` works)
- [ ] Your user can run Docker without sudo (`docker ps` works)
- [ ] Docker is logged into GHCR (`docker login ghcr.io`)
- [ ] Port 5001 is open in Azure NSG
- [ ] UFW firewall allows necessary ports
- [ ] You have the VM's public IP for `SSH_HOST` secret
- [ ] Your SSH public key is in `~/.ssh/authorized_keys` on the VM

---

## Troubleshooting

### Issue: Cannot SSH to VM

**Check:**
```bash
# From local machine
ssh -v azureuser@YOUR_VM_PUBLIC_IP
```

**Solutions:**
- Verify NSG allows port 22
- Check SSH key is correct
- Ensure VM is running in Azure Portal

### Issue: Docker permission denied

**Error:** `permission denied while trying to connect to the Docker daemon socket`

**Solution:**
```bash
sudo usermod -aG docker $USER
newgrp docker
# OR logout and login again
```

### Issue: Cannot pull images from GHCR

**Error:** `unauthorized: authentication required`

**Solution:**
```bash
# Login with correct credentials
docker login ghcr.io -u YOUR_GITHUB_USERNAME
# Use CR_PAT as password

# Verify
docker pull ghcr.io/YOUR_GITHUB_USERNAME/awsome-recipe-cookbook:latest
```

### Issue: docker compose command not found

**Error:** `docker: 'compose' is not a docker command`

**Solution:**
```bash
# Install Docker Compose plugin
sudo apt update
sudo apt install -y docker-compose-plugin

# Verify
docker compose version
```

### Issue: Port 5001 not accessible

**Check Azure NSG:**
1. Go to VM → **Networking** → **Inbound port rules**
2. Verify rule exists for port 5001
3. Add if missing

**Check UFW:**
```bash
sudo ufw status
# If 5001 not listed:
sudo ufw allow 5001/tcp
```

---

## Cost Management

### Estimated Costs (as of 2026)

- **Standard_B1s:** ~$7-10/month (if running 24/7)
- **Standard_B2s:** ~$30-40/month (if running 24/7)

### Cost Saving Tips

**Stop VM when not in use:**
```bash
# Using Azure CLI
az vm deallocate --resource-group recipe-cookbook-rg --name recipe-cookbook-vm

# Start again
az vm start --resource-group recipe-cookbook-rg --name recipe-cookbook-vm
```

**Using Azure Portal:**
1. Go to your VM
2. Click **Stop** (this deallocates and stops billing)
3. Click **Start** when needed

**Auto-shutdown (Recommended for demos):**
1. Go to VM → **Auto-shutdown**
2. Enable and set time (e.g., 11:00 PM daily)
3. Saves money when not actively using

---

## Monitoring and Maintenance

### Check Docker Container Status

```bash
# List running containers
docker ps

# View logs
docker compose logs -f

# Restart containers
docker compose restart
```

### Check Disk Space

```bash
df -h

# Clean up old Docker images
docker system prune -a
```

### Monitor System Resources

```bash
# Install htop
sudo apt install htop

# Run
htop
```

---

## Next Steps

After completing this setup:

1. ✅ Note your VM's public IP → Add to `SSH_HOST` secret
2. ✅ Ensure your SSH private key is added to `SSH_PRIVATE_KEY` secret
3. ✅ Update workflow branch configuration
4. ✅ Test your CI/CD pipeline

---

## Quick Reference Commands

```bash
# SSH to VM
ssh azureuser@YOUR_VM_IP

# Check Docker status
docker ps
docker compose ps

# View application logs
docker compose logs -f

# Restart application
docker compose restart

# Stop application
docker compose down

# Start application
docker compose up -d

# Clean up Docker resources
docker system prune -a

# Check system resources
htop
df -h
free -h
```

---

## Additional Resources

- [Azure VM Documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/)
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
