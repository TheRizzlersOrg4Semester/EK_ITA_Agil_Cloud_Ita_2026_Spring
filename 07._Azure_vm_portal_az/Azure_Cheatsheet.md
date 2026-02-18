# Azure Cheat Sheet for Recipe Cookbook CI/CD

This cheat sheet provides common Azure CLI commands and troubleshooting tips for managing your Recipe Cookbook VM.

## Basic Commands

### Login and Account Management
```bash
# Login to Azure
az login

# Show current account information
az account show

# List available subscriptions
az account list

# Set active subscription
az account set --subscription "SUBSCRIPTION_NAME_OR_ID"

# Logout
az logout
```

### Resource Group Management
```bash
# Create resource group
az group create --name "RESOURCE_GROUP_NAME" --location "LOCATION"

# List resource groups
az group list

# Show resource group details
az group show --name "RESOURCE_GROUP_NAME"

# Delete resource group (be careful!)
az group delete --name "RESOURCE_GROUP_NAME" --yes --no-wait
```

### Virtual Machine Management
```bash
# Create VM
az vm create \
    --resource-group "RESOURCE_GROUP_NAME" \
    --name "VM_NAME" \
    --image Ubuntu2204 \
    --size "Standard_B1s" \
    --admin-username "azureuser" \
    --ssh-key-values "~/.ssh/id_rsa.pub" \
    --public-ip-sku Standard

# List VMs
az vm list --resource-group "RESOURCE_GROUP_NAME"

# Show VM details
az vm show --resource-group "RESOURCE_GROUP_NAME" --name "VM_NAME"

# Start VM
az vm start --resource-group "RESOURCE_GROUP_NAME" --name "VM_NAME"

# Stop VM
az vm stop --resource-group "RESOURCE_GROUP_NAME" --name "VM_NAME"

# Restart VM
az vm restart --resource-group "RESOURCE_GROUP_NAME" --name "VM_NAME"

# Deallocate VM (stops and releases compute resources)
az vm deallocate --resource-group "RESOURCE_GROUP_NAME" --name "VM_NAME"

# Get VM public IP address
az vm show --resource-group "RESOURCE_GROUP_NAME" --name "VM_NAME" --show-details --query publicIps --output tsv
```

### Network Security
```bash
# Open port on VM
az vm open-port \
    --resource-group "RESOURCE_GROUP_NAME" \
    --name "VM_NAME" \
    --port PORT_NUMBER \
    --priority PRIORITY_NUMBER

# List network security group rules
az network nsg rule list --resource-group "RESOURCE_GROUP_NAME" --nsg-name "NSG_NAME"

# Create network security rule
az network nsg rule create \
    --resource-group "RESOURCE_GROUP_NAME" \
    --nsg-name "NSG_NAME" \
    --name "RULE_NAME" \
    --protocol Tcp \
    --direction Inbound \
    --priority PRIORITY_NUMBER \
    --source-address-prefix "*" \
    --destination-address-prefix "*" \
    --destination-port-range PORT_NUMBER

# List all resources in resource group
az resource list --resource-group "RESOURCE_GROUP_NAME"
```

### SSH Access
```bash
# SSH to VM
ssh azureuser@VM_PUBLIC_IP

# SSH with strict host key checking disabled (for scripts)
ssh -o StrictHostKeyChecking=no azureuser@VM_PUBLIC_IP

# Copy files to VM using SCP
scp -r local_folder azureuser@VM_PUBLIC_IP:remote_path

# Run command on VM via SSH
ssh azureuser@VM_PUBLIC_IP "command_to_run"
```

## Troubleshooting

### Common Issues and Solutions

#### Issue: Resource creation failed due to policy restrictions
**Error:** "Resource was disallowed by policy. You can create resources in the following regions..."

**Solution:** Use one of the allowed regions:
- `polandcentral`
- `germanywestcentral`
- `swedencentral`
- `uksouth`
- `norwayeast`

Example:
```bash
az group create --name "my-rg" --location "uksouth"
```

#### Issue: Network interface not found
**Error:** "The Resource 'Microsoft.Network/networkInterfaces/...' was not found"

**Solution:** This is often a timing issue. Wait a few minutes and try again, or check if the resource exists:
```bash
az network nic list --resource-group "RESOURCE_GROUP_NAME"
```

#### Issue: SSH connection refused
**Solutions:**
1. Check if VM is running: `az vm show --resource-group "RESOURCE_GROUP_NAME" --name "VM_NAME" --query powerState`
2. Check if port 22 is open: `az network nsg rule list --resource-group "RESOURCE_GROUP_NAME" --nsg-name "NSG_NAME"`
3. Check the VM's public IP: `az vm show --resource-group "RESOURCE_GROUP_NAME" --name "VM_NAME" --show-details --query publicIps`
4. Wait a few minutes for VM to fully initialize

#### Issue: Azure CLI commands hanging or timing out
**Solutions:**
1. Update Azure CLI: `az upgrade`
2. Clear Azure CLI cache: `az cache purge`
3. Try with `--debug` flag for more information
4. Check your internet connection

## Useful One-Liners

### Get VM public IP
```bash
VM_IP=$(az vm show --resource-group "recipe-cookbook-rg" --name "recipe-cookbook-vm" --show-details --query publicIps --output tsv)
echo "VM IP: $VM_IP"
```

### Test SSH connection
```bash
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 azureuser@VM_IP "echo 'Connection successful'"
```

### List all VMs with their IPs
```bash
az vm list --show-details --query "[].{Name:name, IP:publicIps, State:powerState}" --output table
```

### Check resource group location
```bash
az group show --name "RESOURCE_GROUP_NAME" --query location --output tsv
```

## Region Information

### Allowed Regions for Azure for Students
Based on policy restrictions, you can use these regions:
- `polandcentral` (Poland)
- `germanywestcentral` (Germany)
- `swedencentral` (Sweden)
- `uksouth` (UK South)
- `norwayeast` (Norway)

### Recommended Region
`uksouth` is often recommended as it may reduce costs while providing good performance for European users.

## Cost Management

### Check VM pricing
```bash
az vm list-skus --location "uksouth" --size Standard_B1s --output table
```

### Estimate costs
```bash
az price-sheet show --service-name "Virtual Machines" --location "uksouth"
```

### View current resource costs
```bash
az consumption usage list --include-subscriptions
```

## Cleanup

### Delete all resources
```bash
# This will delete everything in the resource group
az group delete --name "RESOURCE_GROUP_NAME" --yes --no-wait
```

### Delete specific VM
```bash
az vm delete --resource-group "RESOURCE_GROUP_NAME" --name "VM_NAME" --yes
```

## Best Practices

1. **Use allowed regions**: Always use one of the policy-approved regions
2. **Tag your resources**: Add tags for better organization and cost tracking
3. **Use SSH keys**: Always use SSH key authentication instead of passwords
4. **Monitor costs**: Regularly check your Azure usage to avoid surprises
5. **Clean up unused resources**: Delete resources you're not using to save costs
6. **Use smaller VM sizes**: For development, `Standard_B1s` is usually sufficient
7. **Stop VMs when not in use**: Deallocate VMs to save on compute costs

## Quick Reference for Recipe Cookbook Setup

```bash
# Create resource group in allowed region
az group create --name "recipe-cookbook-rg" --location "uksouth"

# Create VM
az vm create \
    --resource-group "recipe-cookbook-rg" \
    --name "recipe-cookbook-vm" \
    --image Ubuntu2204 \
    --size "Standard_B1s" \
    --admin-username "azureuser" \
    --ssh-key-values "~/.ssh/id_rsa.pub" \
    --public-ip-sku Standard

# Open required ports
az vm open-port --resource-group "recipe-cookbook-rg" --name "recipe-cookbook-vm" --port 80 --priority 300
az vm open-port --resource-group "recipe-cookbook-rg" --name "recipe-cookbook-vm" --port 443 --priority 310

# Get VM IP
VM_IP=$(az vm show --resource-group "recipe-cookbook-rg" --name "recipe-cookbook-vm" --show-details --query publicIps --output tsv)
echo "Your VM is ready at: $VM_IP"
```
