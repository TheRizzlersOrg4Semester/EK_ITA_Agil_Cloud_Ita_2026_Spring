#!/bin/bash

# Azure Resource Teardown Script
# This script deletes the entire resource group and all its resources

set -e  # Exit on any error

# Configuration - MUST MATCH azure-setup.sh
RESOURCE_GROUP="recipe-cookbook-rg"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "=========================================="
echo "Azure Resource Teardown"
echo "=========================================="
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI is not installed${NC}"
    exit 1
fi

# Check if logged in to Azure
if ! az account show &> /dev/null; then
    echo -e "${RED}❌ Not logged in to Azure${NC}"
    echo "Please login first: az login"
    exit 1
fi

echo -e "${GREEN}✅ Logged in to Azure${NC}"
ACCOUNT=$(az account show --query name -o tsv)
echo "Using subscription: $ACCOUNT"
echo ""

# Check if resource group exists
if ! az group exists --name "$RESOURCE_GROUP" | grep -q "true"; then
    echo -e "${YELLOW}⚠️  Resource group '$RESOURCE_GROUP' does not exist${NC}"
    echo "Nothing to delete."
    exit 0
fi

# Show what will be deleted
echo "=========================================="
echo "Resources to be deleted:"
echo "=========================================="
echo ""
az resource list --resource-group "$RESOURCE_GROUP" --output table
echo ""

# Confirmation prompt
echo -e "${RED}⚠️  WARNING: This will permanently delete all resources in '$RESOURCE_GROUP'${NC}"
echo ""
read -p "Are you sure you want to continue? (yes/NO): " -r
echo

if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Teardown cancelled."
    exit 0
fi

# Double confirmation for safety
echo ""
echo -e "${RED}⚠️  FINAL CONFIRMATION${NC}"
read -p "Type the resource group name '$RESOURCE_GROUP' to confirm deletion: " -r
echo

if [[ $REPLY != "$RESOURCE_GROUP" ]]; then
    echo -e "${RED}❌ Resource group name doesn't match. Teardown cancelled.${NC}"
    exit 1
fi

# Delete resource group
echo ""
echo "=========================================="
echo "Deleting Resource Group"
echo "=========================================="
echo "Resource Group: $RESOURCE_GROUP"
echo "This may take several minutes..."
echo ""

az group delete \
    --name "$RESOURCE_GROUP" \
    --yes \
    --no-wait

echo -e "${GREEN}✅ Deletion initiated${NC}"
echo ""
echo "The resource group is being deleted in the background."
echo "You can check the status with:"
echo "   ${YELLOW}az group exists --name $RESOURCE_GROUP${NC}"
echo ""
echo "Or wait for completion with:"
echo "   ${YELLOW}az group wait --name $RESOURCE_GROUP --deleted${NC}"
echo ""

# Optional: Wait for deletion to complete
read -p "Do you want to wait for deletion to complete? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Waiting for deletion to complete..."
    if az group wait --name "$RESOURCE_GROUP" --deleted --timeout 300; then
        echo -e "${GREEN}✅ Resource group successfully deleted${NC}"
    else
        echo -e "${YELLOW}⚠️  Deletion is taking longer than expected${NC}"
        echo "Check status in Azure Portal or run:"
        echo "   az group exists --name $RESOURCE_GROUP"
    fi
fi

echo ""
echo "=========================================="
echo "Teardown Complete! 🗑️"
echo "=========================================="
echo ""
echo "All resources in '$RESOURCE_GROUP' have been deleted (or deletion is in progress)."
echo ""
echo "Don't forget to remove GitHub secrets if you're done with this demo:"
echo "   ${YELLOW}gh secret delete SSH_USER${NC}"
echo "   ${YELLOW}gh secret delete SSH_HOST${NC}"
echo "   ${YELLOW}gh secret delete SSH_PRIVATE_KEY${NC}"
echo ""
