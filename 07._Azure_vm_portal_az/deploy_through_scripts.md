# Deploy through scripts

**If you have problems deploying through the portal here is a method to deploy through scripts using `AZ CLI`.**

## Prerequisites

If you are on **Windows** then run the following scripts in `Git Bash`.

---

1. Install `AZ CLI`:

**Win**    
https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?view=azure-cli-latest&pivots=winget

**Mac**    

``` 
brew install azure-cli

```

2. In your terminal run:

```bash
$ az login
```
Log in with your browser to get the subscription id. 

## Provision

1. Create a script. Let's call it `vm_create.sh`. 

If you are on linux/mac you will have to make the script executable:

```bash
$ chmod +x vm_create.sh
```

2. Paste the following into `vm_create.sh`:


```bash
# Variables
RG_NAME="vmtest"
LOCATION="spaincentral"
VM_NAME="vm1"
ADMIN_USER="adminuser"
SSH_KEY_PATH="~/.ssh/id_rsa.pub"
 
# 1. Create Resource Group
az group create --name $RG_NAME --location $LOCATION
 
# 2. Create VM
az vm create \
  --resource-group $RG_NAME \
  --name $VM_NAME \
  --image Ubuntu2204 \
  --size Standard_B1s \
  --admin-username $ADMIN_USER \
  --public-ip-sku Standard \
  --authentication-type ssh \
  --ssh-key-values $SSH_KEY_PATH \
  --output table
 
# 3. Open SSH port
az vm open-port --resource-group $RG_NAME --name $VM_NAME --port 22

# 4. Get and print VM IP address
echo "VM IP Address:"
az vm show --resource-group $RG_NAME --name $VM_NAME --show-details --query publicIps --output tsv
```

3. Change the variables section and use names that makes sense for your purpose. Remember to use the region that you have permission to use. Make sure that the `SSH_KEY_PATH` is valid on your computer.

4. Run the script:

```bash
$ ./vm_create.sh
```

You should now have a server provisioned with an IP address that you can SSH in to.

### Tear down the server

If you need to destroy the server and the resource here is a script. Make sure that the variables are the same as in the create script.

1. Create a file called `vm_destroy.sh`.

If you are on linux/mac you will have to make the script executable:

```bash
$ chmod +x vm_destroy.sh
```

2. In the file paste the following:

```bash
# Variables
RG_NAME="vmtest"
LOCATION="spaincentral"
VM_NAME="vm1"
ADMIN_USER="adminuser"
SSH_KEY_PATH="~/.ssh/id_rsa.pub"

# 1. Delete VM
az vm delete --resource-group $RG_NAME --name $VM_NAME --yes

# 2. Delete Resource Group
az group delete --name $RG_NAME --yes --no-wait
```

3. Run the script

```bash
$ ./vm_destroy.sh
```

Voilà! The server, resource group and everything else has been taken down.


