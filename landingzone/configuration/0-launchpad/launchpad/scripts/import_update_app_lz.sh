#!/bin/bash


#------------------------------------------------------------------------
# functions
#------------------------------------------------------------------------
# Define a timestamp function
timestamp() {
  date +"%T" # current time
}
#------------------------------------------------------------------------
# end functions
#------------------------------------------------------------------------

echo "working directory:"
CWD=$(pwd)
echo $CWD

CONFIG_FILE_PATH="./../scripts/config.yaml"
echo $CONFIG_FILE_PATH

# Define your variables

RESOURCE_GROUP_NAME=$(yq -r '.resource_group_name' $CONFIG_FILE_PATH)
echo $RESOURCE_GROUP_NAME
LOG_ANALYTICS_WORKSPACE_RESOURCE_GROUP_NAME=$(yq -r '.log_analytics_workspace_resource_group_name' $CONFIG_FILE_PATH)
echo $LOG_ANALYTICS_WORKSPACE_RESOURCE_GROUP_NAME
LOG_ANALYTICS_WORKSPACE_NAME=$(yq -r '.log_analytics_workspace_name' $CONFIG_FILE_PATH)
echo $LOG_ANALYTICS_WORKSPACE_NAME
PROJECT_CODE=$(yq -r '.prefix' $CONFIG_FILE_PATH)
echo $PROJECT_CODE

# Generate resource group name to store state file
RG_NAME="${PROJECT_CODE}-rg-launchpad"
echo "Resource Group Name: ${RG_NAME}"

STORAGE_ACCOUNT_NAME_PREFIX="${PROJECT_CODE}stgtfstate"
STORAGE_ACCOUNT_NAME_PREFIX="${STORAGE_ACCOUNT_NAME_PREFIX//-/}"
STORAGE_ACCOUNT_INFO=$(az storage account list --resource-group $RG_NAME --query "[?contains(name, '$STORAGE_ACCOUNT_NAME_PREFIX')]" 2> /dev/null)
if [[ $? -ne 0 ]]; then
    echo "no storage account"
    exit 1
else
    # echo $STORAGE_ACCOUNT_INFO
    STG_NAME=$(echo "$STORAGE_ACCOUNT_INFO" | jq ".[0].name" -r)
    echo "Storage Account Name: ${STG_NAME}"

    echo "updating gcci_platform tfstate..."
    ACCOUNT_INFO=$(az account show 2> /dev/null)
    if [[ $? -ne 0 ]]; then
        echo "no subscription"
        exit
    fi

    SUB_ID=$(echo "$ACCOUNT_INFO" | jq ".id" -r)
    SUB_NAME=$(echo "$ACCOUNT_INFO" | jq ".name" -r)
    USER_NAME=$(echo "$ACCOUNT_INFO" | jq ".user.name" -r)

    echo "Subscription Id: ${SUB_ID}"
    echo "Subscription Name: ${SUB_NAME}"
    SUBSCRIPTION_ID="${SUB_ID}" # "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx"


    MSYS_NO_PATHCONV=1 terraform init  -reconfigure \
    -backend-config="resource_group_name=${RG_NAME}" \
    -backend-config="storage_account_name=${STG_NAME}" \
    -backend-config="container_name=0-launchpad" \
    -backend-config="key=gcci-platform.tfstate"

    # log analytics workspace
    MSYS_NO_PATHCONV=1 terraform state rm azurerm_log_analytics_workspace.gcci_agency_workspace

    MSYS_NO_PATHCONV=1 terraform import "azurerm_log_analytics_workspace.gcci_agency_workspace" "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/${LOG_ANALYTICS_WORKSPACE_RESOURCE_GROUP_NAME}/providers/Microsoft.OperationalInsights/workspaces/${LOG_ANALYTICS_WORKSPACE_NAME}" 


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



fi
