# ----------------------------------------------------------------
# "public_network_access_enabled = false" in terraform code or 
# manually disabled the Public Network Access via Azure Portal UI or Bash script.
# Issue Reference: 3 & 5
# ----------------------------------------------------------------
# Variables
prefix="maa31-stg"
resourceGroup="rg-${prefix}-platform"


diskName="dsk-xxxxx-stg-lun0-0-kb5"
# Disable public access
az disk update \
  --name "$diskName" \
  --resource-group "$resourceGroup" \
  --public-network-access Disabled
  
diskName="vmxxxxxxxxxx0kb5_OsDisk_1_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
# Disable public access
az disk update \
  --name "$diskName" \
  --resource-group "$resourceGroup" \
  --public-network-access Disabled
