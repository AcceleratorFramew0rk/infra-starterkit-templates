#!/bin/bash

#------------------------------------------------------------------------
# USAGE:
# cd /tf/avm/templates/landingzone/configuration/0-launchpad/launchpad
# ./scripts/import.sh
#------------------------------------------------------------------------

#------------------------------------------------------------------------
# functions
#------------------------------------------------------------------------

get_vnet_cidr() {
  local resourcegroup=$1
  local vnetname=$2

  # Query the CIDR (address prefixes) of the virtual network
  vnet_cidr=$(az network vnet show \
    --resource-group "$resourcegroup" \
    --name "$vnetname" \
    --query "addressSpace.addressPrefixes[0]" \
    --output tsv)

  # Output the retrieved CIDR
  echo "$vnet_cidr"
}

generate_random_string() {
    echo $(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 3 | head -n 1 | tr '[:upper:]' '[:lower:]')
}

# Define a timestamp function
timestamp() {
  date +"%T" # current time
}

#------------------------------------------------------------------------
# end functions
#------------------------------------------------------------------------

#------------------------------------------------------------------------
# init all folders and terraform.tf files
#------------------------------------------------------------------------

echo "init files"

#------------------------------------------------------------------------
# get current subscriptin information
#------------------------------------------------------------------------

ACCOUNT_INFO=$(az account show 2> /dev/null)
if [[ $? -ne 0 ]]; then
    echo "no subscription"
    exit 1
fi

SUB_ID=$(echo "$ACCOUNT_INFO" | jq ".id" -r)
SUB_NAME=$(echo "$ACCOUNT_INFO" | jq ".name" -r)
USER_NAME=$(echo "$ACCOUNT_INFO" | jq ".user.name" -r)

STATUS_LINE="$USER_NAME @"

if [[ "$SUB_ID" == "MY_PERSONAL_SUBSCRIPTION_ID" ]]; then
    STATUS_LINE="$STATUS_LINE 🏠"
elif [[ "$SUB_ID" == "MY_WORK_SUBSCRIPTION_ID" ]]; then
    STATUS_LINE="$STATUS_LINE 🏢"
else
    STATUS_LINE="$STATUS_LINE $SUB_NAME"
fi

echo "Subscription Id: ${SUB_ID}"
echo "Subscription Name: ${SUB_NAME}"
echo "${STATUS_LINE}"

#------------------------------------------------------------------------
# read config.yaml file data
#------------------------------------------------------------------------

echo "working directory:"
CWD=$(pwd)
echo $CWD
CONFIG_FILE_PATH="./../scripts/config.yaml"
echo $CONFIG_FILE_PATH

#------------------------------------------------------------------------
# generate templates
#------------------------------------------------------------------------

RESOURCE_GROUP_NAME=$(yq -r '.resource_group_name' $CONFIG_FILE_PATH)
echo $RESOURCE_GROUP_NAME
LOG_ANALYTICS_WORKSPACE_RESOURCE_GROUP_NAME=$(yq -r '.log_analytics_workspace_resource_group_name' $CONFIG_FILE_PATH)
echo $LOG_ANALYTICS_WORKSPACE_RESOURCE_GROUP_NAME
LOG_ANALYTICS_WORKSPACE_NAME=$(yq -r '.log_analytics_workspace_name' $CONFIG_FILE_PATH)
echo $LOG_ANALYTICS_WORKSPACE_NAME

# Define your variables

PROJECT_CODE=$(yq -r '.prefix' $CONFIG_FILE_PATH)

echo $PROJECT_CODE
SUBSCRIPTION_ID="${SUB_ID}" 

# Generate resource group name to store state file
RG_NAME="rg-${PROJECT_CODE}-launchpad"

# Location
LOC=$(yq -r '.location' $CONFIG_FILE_PATH)
echo $LOC

RND_NUM=$(LC_ALL=C tr -dc 'a-z0-9' </dev/urandom | head -c 3)
echo "Generated Code: $RND_NUM"
STG_NAME="stg${PROJECT_CODE}tfstate${RND_NUM}"
echo $STG_NAME
STG_NAME="${STG_NAME//-/}"
echo $STG_NAME
CONTAINER1="0-launchpad"
CONTAINER2="1-landingzones"
CONTAINER3="2-solution-accelerators"

echo " "
echo "Random string: ${RND_NUM}"
echo "Resource Group Name: ${RG_NAME}"
echo "Storage Account Name: ${STG_NAME}"

echo "-----------------------------------------------------------------------------"  
echo "Begin launchpad storage account"  
timestamp
echo "-----------------------------------------------------------------------------"  

# Check if the resource group already exists
az group show --name $RG_NAME > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "ERROR: Resource group $RG_NAME already exists. Exiting."
    exit 1
else
    # If the resource group does not exist, attempt to create it
    az group create --name $RG_NAME --location $LOC
    if [ $? -eq 0 ]; then
        echo "Resource group $RG_NAME created successfully."
    else
        echo "ERROR: Failed to create resource group $RG_NAME. Exiting."
        exit 1
    fi
fi
# Create Storage account and containers for storing state files
if [ $? -eq 0 ]; then
  az storage account create --name $STG_NAME --resource-group $RG_NAME --location $LOC --sku Standard_LRS --kind StorageV2 --allow-blob-public-access true --min-tls-version TLS1_2
  if [ $? -ne 0 ]; then
    echo -e "     "
    echo -e "\e[31mStorage account create failed. Exiting.\e[0m"
    exit 1
  fi 
fi
if [ $? -eq 0 ]; then
  az storage container create --account-name $STG_NAME --name $CONTAINER1 --public-access blob --fail-on-exist
  if [ $? -ne 0 ]; then
    echo -e "     "
    echo -e "\e[31mStorage container create failed. Exiting.\e[0m"
    exit 1
  fi 
fi
if [ $? -eq 0 ]; then
  az storage container create --account-name $STG_NAME --name $CONTAINER2 --public-access blob --fail-on-exist
  if [ $? -ne 0 ]; then
    echo -e "     "
    echo -e "\e[31mStorage container create failed. Exiting.\e[0m"
    exit 1
  fi 
fi
if [ $? -eq 0 ]; then
  az storage container create --account-name $STG_NAME --name $CONTAINER3 --public-access blob --fail-on-exist
  if [ $? -ne 0 ]; then
    echo -e "     "
    echo -e "\e[31mStorage container create failed. Exiting.\e[0m"
    exit 1
  fi 
fi


RESOURCE_GROUP_NAME

# custom resource group - single resoruce group feature
if [[ "$RESOURCE_GROUP_NAME" != "gcci-platform" ]]; then
  # If the resource group does not exist, attempt to create it
  az group create --name $RESOURCE_GROUP_NAME --location $LOC
  if [ $? -eq 0 ]; then
      echo "Resource group $RESOURCE_GROUP_NAME created successfully."
  else
      echo "ERROR: Failed to create resource group $RESOURCE_GROUP_NAME. Exiting."
      exit 1
  fi
fi


echo "-----------------------------------------------------------------------------"  
echo "End launchpad storage account"  
timestamp
echo "-----------------------------------------------------------------------------"  

echo "-----------------------------------------------------------------------------"  
echo "Start replacing variables"  
timestamp
echo "-----------------------------------------------------------------------------"  

echo "-----------------------------------------------------------------------------"  
echo "Start terraform import commands"  
timestamp
echo "-----------------------------------------------------------------------------"  

MSYS_NO_PATHCONV=1 terraform init  -reconfigure \
-backend-config="resource_group_name=$RG_NAME" \
-backend-config="storage_account_name=$STG_NAME" \
-backend-config="container_name=0-launchpad" \
-backend-config="key=gcci-platform.tfstate"

# Variables for VNET Name
CONFIG_vnets_project_name=""
CONFIG_vnets_devops_name=""
CONFIG_vnets_hub_ingress_internet_name=""
CONFIG_vnets_hub_egress_internet_name=""
CONFIG_vnets_hub_ingress_intranet_name=""
CONFIG_vnets_hub_egress_intranet_name=""
CONFIG_vnets_management_name=""

CONFIG_vnets_project_name=$(yq -r '.vnets.project.name' $CONFIG_FILE_PATH)
CONFIG_vnets_devops_name=$(yq -r '.vnets.devops.name' $CONFIG_FILE_PATH)
CONFIG_vnets_hub_ingress_internet_name=$(yq -r '.vnets.hub_ingress_internet.name' $CONFIG_FILE_PATH)
CONFIG_vnets_hub_egress_internet_name=$(yq -r '.vnets.hub_egress_internet.name' $CONFIG_FILE_PATH)
CONFIG_vnets_hub_ingress_intranet_name=$(yq -r '.vnets.hub_ingress_intranet.name' $CONFIG_FILE_PATH)
CONFIG_vnets_hub_egress_intranet_name=$(yq -r '.vnets.hub_egress_intranet.name' $CONFIG_FILE_PATH)
CONFIG_vnets_management_name=$(yq -r '.vnets.management.name' $CONFIG_FILE_PATH)
VNET_RESOURCE_GROUP_NAME="gcci-platform"

if [[ "$CONFIG_vnets_hub_ingress_internet_name" == null ]]; then
  CONFIG_vnets_hub_ingress_internet_name=""
fi
if [[ "$CONFIG_vnets_hub_egress_internet_name" == null ]]; then
  CONFIG_vnets_hub_egress_internet_name=""
fi
if [[ "$CONFIG_vnets_hub_ingress_intranet_name" == null ]]; then
  CONFIG_vnets_hub_ingress_intranet_name=""
fi
if [[ "$CONFIG_vnets_hub_egress_intranet_name" == null ]]; then
  CONFIG_vnets_hub_egress_intranet_name=""
fi
if [[ "$CONFIG_vnets_management_name" == null ]]; then
  CONFIG_vnets_management_name=""
fi
if [[ "$CONFIG_vnets_project_name" == null ]]; then
  CONFIG_vnets_project_name=""
fi
if [[ "$CONFIG_vnets_devops_name" == null ]]; then
  CONFIG_vnets_devops_name=""
fi

echo "vnets:" 
echo "CONFIG_vnets_hub_ingress_internet_name: ${CONFIG_vnets_hub_ingress_internet_name}"
echo "CONFIG_vnets_hub_egress_internet_name: ${CONFIG_vnets_hub_egress_internet_name}"
echo "CONFIG_vnets_hub_ingress_intranet_name: ${CONFIG_vnets_hub_ingress_intranet_name}"
echo "CONFIG_vnets_hub_egress_intranet_name: ${CONFIG_vnets_hub_egress_intranet_name}"
echo "CONFIG_vnets_management_name: ${CONFIG_vnets_management_name}"
echo "CONFIG_vnets_project_name: ${CONFIG_vnets_project_name}"
echo "CONFIG_vnets_devops_name: ${CONFIG_vnets_devops_name}"

# resource group
terraform import "azurerm_resource_group.gcci_platform" "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/${VNET_RESOURCE_GROUP_NAME}" 
if [ $? -ne 0 ]; then
  echo -e "     "
  echo -e "\e[31mTerraform import failed. Exiting.\e[0m"
  exit 1
fi 
terraform import "azurerm_resource_group.gcci_agency_law" "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/${LOG_ANALYTICS_WORKSPACE_RESOURCE_GROUP_NAME}" 
if [ $? -ne 0 ]; then
  echo -e "     "
  echo -e "\e[31mTerraform import failed. Exiting.\e[0m"
  exit 1
fi 

# virtual networks
if [[ "$CONFIG_vnets_hub_ingress_internet_name" != "" ]]; then
  terraform import "azurerm_virtual_network.gcci_vnet_ingress_internet" "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/${VNET_RESOURCE_GROUP_NAME}/providers/Microsoft.Network/virtualNetworks/$CONFIG_vnets_hub_ingress_internet_name" 
  if [ $? -ne 0 ]; then
    echo -e "     "
    echo -e "\e[31mTerraform import failed. Exiting.\e[0m"
    exit 1
  fi 
fi

if [[ "$CONFIG_vnets_hub_egress_internet_name" != "" ]]; then
  terraform import "azurerm_virtual_network.gcci_vnet_egress_internet" "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/${VNET_RESOURCE_GROUP_NAME}/providers/Microsoft.Network/virtualNetworks/$CONFIG_vnets_hub_egress_internet_name" 
  if [ $? -ne 0 ]; then
    echo -e "     "
    echo -e "\e[31mTerraform import failed. Exiting.\e[0m"
    exit 1
  fi 
fi

if [[ "$CONFIG_vnets_hub_ingress_intranet_name" != "" ]]; then
  terraform import "azurerm_virtual_network.gcci_vnet_ingress_intranet" "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/${VNET_RESOURCE_GROUP_NAME}/providers/Microsoft.Network/virtualNetworks/$CONFIG_vnets_hub_ingress_intranet_name" 
  if [ $? -ne 0 ]; then
    echo -e "     "
    echo -e "\e[31mTerraform import failed. Exiting.\e[0m"
    exit 1
  fi 
fi

if [[ "$CONFIG_vnets_hub_egress_intranet_name" != "" ]]; then
  terraform import "azurerm_virtual_network.gcci_vnet_egress_intranet" "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/${VNET_RESOURCE_GROUP_NAME}/providers/Microsoft.Network/virtualNetworks/$CONFIG_vnets_hub_egress_intranet_name" 
  if [ $? -ne 0 ]; then
    echo -e "     "
    echo -e "\e[31mTerraform import failed. Exiting.\e[0m"
    exit 1
  fi 
fi

if [[ "$CONFIG_vnets_management_name" != "" ]]; then
  terraform import "azurerm_virtual_network.gcci_vnet_management" "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/${VNET_RESOURCE_GROUP_NAME}/providers/Microsoft.Network/virtualNetworks/$CONFIG_vnets_management_name" 
  if [ $? -ne 0 ]; then
    echo -e "     "
    echo -e "\e[31mTerraform import failed. Exiting.\e[0m"
    exit 1
  fi 
fi

if [[ "$CONFIG_vnets_project_name" != "" ]]; then
  terraform import "azurerm_virtual_network.gcci_vnet_project" "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/${VNET_RESOURCE_GROUP_NAME}/providers/Microsoft.Network/virtualNetworks/$CONFIG_vnets_project_name" 
  if [ $? -ne 0 ]; then
    echo -e "     "
    echo -e "\e[31mTerraform import failed. Exiting.\e[0m"
    exit 1
  fi 
fi

if [[ "$CONFIG_vnets_devops_name" != "" ]]; then
  terraform import "azurerm_virtual_network.gcci_vnet_devops" "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/${VNET_RESOURCE_GROUP_NAME}/providers/Microsoft.Network/virtualNetworks/$CONFIG_vnets_devops_name" 
  if [ $? -ne 0 ]; then
    echo -e "     "
    echo -e "\e[31mTerraform import failed. Exiting.\e[0m"
    exit 1
  fi 
fi


# log analytics workspace
terraform import "azurerm_log_analytics_workspace.gcci_agency_workspace" "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/${LOG_ANALYTICS_WORKSPACE_RESOURCE_GROUP_NAME}/providers/Microsoft.OperationalInsights/workspaces/${LOG_ANALYTICS_WORKSPACE_NAME}" 
if [ $? -ne 0 ]; then
  echo -e "     "
  echo -e "\e[31mTerraform import failed. Exiting.\e[0m"
  exit 1
fi 

echo "-----------------------------------------------------------------------------"  
echo "End import gcci resources"  
timestamp
echo "-----------------------------------------------------------------------------"

# # Wait for the user to press enter before closing
echo "output:"
echo "RESOURCE_GROUP_NAME: ${RG_NAME}"
echo "STORAGE_ACCONT_NAME: ${STG_NAME}"


echo "-----------------------------------------------------------------------------"  
echo "Start creating NSG yaml configuration file"  
timestamp
echo "-----------------------------------------------------------------------------"

# goto starter kit parent folder
cd ./../../../../

# Get the folder name
FOLDER_NAME=$(basename "$(pwd)")
echo "Folder Name: ${FOLDER_NAME}"

# goto nsg configuration folder
cd ./landingzone/configuration/1-landingzones/scripts

# create nsg yaml file from nsg csv files
python3 csv_to_yaml.py 

# replace subnet cidr range from config.yaml file in launchpad
./replace.sh


echo "-----------------------------------------------------------------------------"  
echo "End creating NSG yaml configuration file"  
timestamp
echo "-----------------------------------------------------------------------------"

