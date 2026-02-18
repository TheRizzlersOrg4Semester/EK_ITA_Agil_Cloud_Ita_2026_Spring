#!/bin/bash

# Azure VM Setup Script for CI/CD Demo
# This script creates everything needed for the Recipe Cookbook deployment

set -e  # Exit on any error

# Configuration variables - CUSTOMIZE THESE
RESOURCE_GROUP="recipe-cookbook-rg"
LOCATION="norwayeast"  # Change to your preferred region (e.g., "eastus", "northeurope")
VM_NAME="recipe-cookbook-vm"
VM_SIZE="Standard_B1s"  # Change to "Standard_B2s" for better performance
ADMIN_USERNAME="azureuser"
SSH_KEY_PATH="$HOME/.ssh/id_rsa.pub"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "=========================================="
echo "Azure VM Setup for Recipe Cookbook"
echo "=========================================="
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI is not installed${NC}"
    echo "Install it from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

echo -e "${GREEN}✅ Azure CLI is installed${NC}"

# Check if logged in to Azure
echo ""
echo "Checking Azure login status..."
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}⚠️  Not logged in to Azure${NC}"
    echo "Logging in..."
    az login
else
    echo -e "${GREEN}✅ Already logged in to Azure${NC}"
    ACCOUNT=$(az account show --query name -o tsv)
    echo "Using subscription: $ACCOUNT"
fi

# Check if SSH key exists
echo ""
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo -e "${YELLOW}⚠️  SSH key not found at $SSH_KEY_PATH${NC}"
    echo "Generating new SSH key..."
    ssh-keygen -t rsa -b 4096 -f "${SSH_KEY_PATH%.pub}" -N "" -C "azure-vm-cicd"
    echo -e "${GREEN}✅ SSH key generated${NC}"
else
    echo -e "${GREEN}✅ SSH key found at $SSH_KEY_PATH${NC}"
fi

# Create resource group
echo ""
echo "=========================================="
echo "Creating Resource Group"
echo "=========================================="
echo "Name: $RESOURCE_GROUP"
echo "Location: $LOCATION"

if az group exists --name "$RESOURCE_GROUP" | grep -q "true"; then
    echo -e "${YELLOW}⚠️  Resource group already exists${NC}"
    read -p "Do you want to delete and recreate it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Deleting existing resource group..."
        az group delete --name "$RESOURCE_GROUP" --yes --no-wait
        echo "Waiting for deletion to complete..."
        sleep 10
    else
        echo "Using existing resource group"
    fi
fi

if ! az group exists --name "$RESOURCE_GROUP" | grep -q "true"; then
    az group create \
        --name "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --output table
    echo -e "${GREEN}✅ Resource group created${NC}"
fi

# Create Virtual Machine
echo ""
echo "=========================================="
echo "Creating Virtual Machine"
echo "=========================================="
echo "VM Name: $VM_NAME"
echo "Size: $VM_SIZE"
echo "Admin User: $ADMIN_USERNAME"
echo "This may take 2-5 minutes..."
echo ""

az vm create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --image Ubuntu2204 \
    --size "$VM_SIZE" \
    --admin-username "$ADMIN_USERNAME" \
    --ssh-key-values "$SSH_KEY_PATH" \
    --public-ip-sku Standard \
    --output table

echo -e "${GREEN}✅ Virtual machine created${NC}"

# Open required ports
echo ""
echo "=========================================="
echo "Configuring Network Security"
echo "=========================================="
echo "Opening ports: 22 (SSH), 80 (HTTP), 443 (HTTPS)"

az vm open-port \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --port 80 \
    --priority 300 \
    --output table

az vm open-port \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --port 443 \
    --priority 310 \
    --output table

echo -e "${GREEN}✅ Ports configured${NC}"

# Get VM public IP
echo ""
echo "=========================================="
echo "Getting VM Information"
echo "=========================================="

VM_IP=$(az vm show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --show-details \
    --query publicIps \
    --output tsv)

echo -e "${GREEN}✅ VM is ready!${NC}"
echo ""
echo "VM Public IP: ${GREEN}$VM_IP${NC}"
echo "SSH command: ${YELLOW}ssh $ADMIN_USERNAME@$VM_IP${NC}"

# Test SSH connection
echo ""
echo "Testing SSH connection..."
if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$ADMIN_USERNAME@$VM_IP" "echo 'Connection successful'" &> /dev/null; then
    echo -e "${GREEN}✅ SSH connection successful${NC}"
else
    echo -e "${YELLOW}⚠️  SSH connection failed. VM may still be initializing. Wait a minute and try again.${NC}"
fi

# Install Docker on the VM
echo ""
read -p "Do you want to install Docker on the VM now? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo ""
    echo "=========================================="
    echo "Installing Docker on VM"
    echo "=========================================="

    ssh -o StrictHostKeyChecking=no "$ADMIN_USERNAME@$VM_IP" << 'ENDSSH'
        set -e
        echo "Updating package index..."
        sudo apt update

        echo "Installing prerequisites..."
        sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

        echo "Adding Docker GPG key..."
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

        echo "Adding Docker repository..."
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        echo "Installing Docker and Docker Compose..."
        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

        echo "Adding user to docker group..."
        sudo usermod -aG docker $USER

        echo "Enabling UFW firewall..."
        sudo ufw --force enable
        sudo ufw allow 22/tcp
        sudo ufw allow 80/tcp
        sudo ufw allow 443/tcp

        echo "Creating app directory..."
        mkdir -p ~/app

        echo "Docker installation complete!"
        docker --version
        docker compose version
ENDSSH

    echo -e "${GREEN}✅ Docker installed successfully${NC}"
    echo -e "${YELLOW}⚠️  Note: You need to logout and login again for docker group changes to take effect${NC}"
fi

# Summary
echo ""
echo "=========================================="
echo "Setup Complete! 🎉"
echo "=========================================="
echo ""
echo "Resource Group: ${GREEN}$RESOURCE_GROUP${NC}"
echo "VM Name: ${GREEN}$VM_NAME${NC}"
echo "VM Public IP: ${GREEN}$VM_IP${NC}"
echo "Admin Username: ${GREEN}$ADMIN_USERNAME${NC}"
echo ""
echo "=========================================="
echo "Next Steps:"
echo "=========================================="
echo ""
echo "1. SSH to your VM (logout and login if Docker was installed):"
echo "   ${YELLOW}ssh $ADMIN_USERNAME@$VM_IP${NC}"
echo ""
echo "2. Login to GitHub Container Registry on the VM:"
echo "   ${YELLOW}docker login ghcr.io -u YOUR_GITHUB_USERNAME${NC}"
echo "   (Use your CR_PAT token as password)"
echo ""
echo "3. Add these secrets to your GitHub repository:"
echo "   ${YELLOW}SSH_USER${NC} = $ADMIN_USERNAME"
echo "   ${YELLOW}SSH_HOST${NC} = $VM_IP"
echo "   ${YELLOW}SSH_PRIVATE_KEY${NC} = Contents of ~/.ssh/id_rsa"
echo ""
echo "4. Quick secret setup with GitHub CLI:"
echo "   ${YELLOW}echo \"$ADMIN_USERNAME\" | gh secret set SSH_USER${NC}"
echo "   ${YELLOW}echo \"$VM_IP\" | gh secret set SSH_HOST${NC}"
echo "   ${YELLOW}gh secret set SSH_PRIVATE_KEY < ~/.ssh/id_rsa${NC}"
echo ""
echo "=========================================="
echo ""
echo "To delete everything later, run:"
echo "   ${RED}./azure-teardown.sh${NC}"
echo ""
