# Echo the contents of ./config.yaml
echo "config.yaml content:"
# cat ./config.yaml
cat ./starterkit/templates/landingzone/configuration/0-launchpad/scripts/config.yaml
PREFIX=$(yq -r '.prefix' './config.yaml')
RG_NAME="${PREFIX}-rg-launchpad"
echo "Resource Group name: ${RG_NAME}"

# Try to get the storage account name
STG_NAME=$(az storage account list \
  --resource-group "$RG_NAME" \
  --query "[?contains(name, '${PREFIX//-/}stgtfstate')].[name]" \
  -o tsv 2>/dev/null | head -n 1)

# Check if the command failed or STG_NAME is empty
if [ $? -ne 0 ] || [ -z "$STG_NAME" ]; then

  echo "No existing storage account: ${STG_NAME}"

  # ** IMPORTANT: cd to the directory where the script is located
  cd ./starterkit/templates/landingzone/configuration/0-launchpad/launchpad
  echo "Start importing vnet tfstate"            
  ./scripts/import_app_lz.sh
  if [ $? -ne 0 ]; then
    echo "Failed to import vnet tfstate. Exiting."
    exit 1
  fi

else

  echo "Storage Account name: ${STG_NAME}"
  echo "Using existing Resource group and storage account"
  echo "Start updating tfstate config info"    
  # ** IMPORTANT: cd to the directory where the script is located        
  cd ./starterkit/templates/landingzone/configuration/0-launchpad/launchpad
  ./scripts/import_update_app_lz.sh
  if [ $? -ne 0 ]; then
    echo "Failed to import vnet tfstate. Exiting."
    exit 1
  fi

fi