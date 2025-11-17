### **Version 0.1.2 (31 Nov 2025)**
#### **Compatibility:**
- **AAF AVM SDE:** `acceleratorframew0rk/gccstarterkit-avm-sde:terraform-1.13.1`
- **Azurerm:** Version 4.0
- **AAF:** Version 0.0.21
- **AVM Resource Modules:** 
| S/N | Azure Services                 | Current Version | Latest Version | AVM                                              |
|-----|--------------------------------|-----------------|----------------|--------------------------------------------------|
| ✔️1   | acr                            | 0.4.0           | 0.4.0          | Azure/avm-res-containerregistry-registry/azurerm |
| ✔️2   | ai_foundry_enterprise          | 0.8.0           | 0.8.0          | Azure/avm-res-machinelearningservices-workspace/azurerm |
| 3   | ai_search_service                 | 0.1.5           | 0.2            | Azure/avm-res-search-searchservice/azurerm |
| ✔️4   | aks_avm_ptn                    | 0.0.21          | 0.0.21         | custom "compute/terraform-azurerm-avm-ptn-aks-production" |
| 5   | apim                           | 0.0.1           | 0.0.4          | Azure/avm-res-apimanagement-service/azurerm |
| 6   | app_service                    | 0.17.0          | 0.17.2         | Azure/avm-res-web-site/azurerm  |
| 7   | container_app                  | 0.6.0           | 0.7.0          | Azure/avm-res-app-containerapp/azurerm |
| 8   | container_instance             | 0.1.0           | 0.1.0          | Azure/avm-res-containerinstance-containergroup/azurerm |
| 9   | cosmos_db_mongo                | 0.8.0           | 0.9.0          | Azure/avm-res-documentdb-databaseaccount/azurerm |
| 10  | cosmos_db_sql                  | 0.8.0           | 0.9.0          | Azure/avm-res-documentdb-databaseaccount/azurerm |
| ✔️11  | data_explorer                  | latest          | latest         | custom "iot/data-explorer" |
| ✔️12  | event_hubs                     | latest          | latest         | custom "iot/event-hubs" |
| ✔️13  | iot_hub                        | latest          | latest         | custom "iot/iot-hub" |
| 14  | keyvault                       | 0.10.0          | 0.10.1         | Azure/avm-res-keyvault-vault/azurerm |
| 15  | linux_function_app             | 0.9.0           | 0.17.2         | Azure/avm-res-web-site/azurerm |
| 16  | logic_app                      | 0.17.0          | 0.17.2         | Azure/avm-res-web-site/azurerm |
| ✔️17  | mssql                          | 0.1.5           | 0.1.5          | Azure/avm-res-sql-server/azurerm |
| ✔️18  | notification_hub               | N.A.            | N.A.           | resource "azurerm_notification_hub_namespace" |
| ✔️19  | postgresql                     | 0.1.4           | 0.1.4          | Azure/avm-res-dbforpostgresql-flexibleserver/azurerm |
| ✔️20  | redis_cache                    | 0.4.0           | 0.4.0          | Azure/avm-res-cache-redis/azurerm |
| 21  | search_service                 | 0.1.5           | 0.2.0          | Azure/avm-res-search-searchservice/azurerm |
| 22  | service_bus                    | 0.1.0           | 0.4.0          | Azure/avm-res-servicebus-namespace/azurerm |
| 23  | storage_account                | 0.6.3           | 0.6.4          | Azure/avm-res-storage-storageaccount/azurerm |
| ✔️24  | stream_analytics               | latest          | latest         | custom "iot/stream-analytics" |
| ✔️25  | vm                             | 0.19.3          | 0.19.3         | Azure/avm-res-compute-virtualmachine/azurerm |
| ✔️26  | vmss_linux                     | 0.7.1           |                | Azure/avm-res-compute-virtualmachinescaleset/azurerm |
| ✔️27  | vmss_windows                   | 0.7.1           |                | Azure/avm-res-compute-virtualmachinescaleset/azurerm |
| ✔️28  | subnet                         | 0.16.0          | 0.16.0         | Azure/avm-res-network-virtualnetwork/azurerm//modules/subnet |

#### **New Features:**
- add new feature to use Azure Developer CLI (azd)
- add Virtual Machine Landing Zone using avd

#### **Enhancements:**
- *Upgrade Virtual Subnets to avm version = "0.16.0"* 


#### **Bug Fixes:**
- *No Bug Fixes added in this release.*

---

### **Version 0.1.1 (31 Sep 2025)**
#### **Compatibility:**
- **AAF AVM SDE:** `gccstarterkit/gccstarterkit-avm-sde:0.3`
- **Azurerm:** Version 4.0
- **AAF:** Version 0.0.20

#### **New Features:**
- add a new pattern "ai_search_services" of ai services, search services and storage account

#### **Enhancements:**
- *Upgrade Apim to avm v0.0.1.*
- *Upgrade Keyvault to avm v0.10.0.*
- *Upgrade CosmosDb Mongo to avm v0.8.0.*
- *Upgrade CosmosDb SQL to avm v0.8.0.*
- *Upgrade SQLServer to avm v0.1.5.*
- *Upgrade AppService to avm v0.17.0.*
- *Upgrade LogicApp to avm v0.17.0.*
- *Upgrade Postgresql to avm v0.1.4.*
- *Upgrade RedisCache to avm v0.4.0.*
- *Upgrade SearchService to avm v0.1.5.*
- *Upgrade Ingress Internet Azure Firewall to avm v0.3.0.*
- *Upgrade Ingress Intranet Azure Firewall to avm v0.3.0.*
- *Upgrade Azure Virtual Machine to avm v0.19.3.*
- *Upgrade VMSS Windows to avm v0.7.1".*
- *Upgrade VMSS Linux to avm v0.7.1".*
- *Change path of config.yaml to /tf/avm/config/config.yaml.*


#### **Bug Fixes:**
- *No Bug Fixes added in this release.*

---


### **Version 0.1.0 (15 Jun 2025)**
#### **Compatibility:**
- **AAF AVM SDE:** `gccstarterkit/gccstarterkit-avm-sde:0.3`
- **Azurerm:** Version 4.0
- **AAF:** Version 0.0.20

#### **New Features:**
- add a new pattern "ai_search_services" of ai services, search services and storage account

#### **Enhancements:**
- *Upgrade Apim to avm v0.0.1.*
- *Upgrade Keyvault to avm v0.10.0.*
- *Upgrade CosmosDb Mongo to avm v0.8.0.*
- *Upgrade CosmosDb SQL to avm v0.8.0.*
- *Upgrade SQLServer to avm v0.1.5.*
- *Upgrade AppService to avm v0.17.0.*
- *Upgrade LogicApp to avm v0.17.0.*
- *Upgrade Postgresql to avm v0.1.4.*
- *Upgrade RedisCache to avm v0.4.0.*
- *Upgrade SearchService to avm v0.1.5.*
- *Upgrade Ingress Internet Azure Firewall to avm v0.3.0.*
- *Upgrade Ingress Intranet Azure Firewall to avm v0.3.0.*
- *Upgrade Azure Virtual Machine to avm v0.19.3.*
- *Upgrade VMSS Windows to avm v0.7.1".*
- *Upgrade VMSS Linux to avm v0.7.1".*
- *Change path of config.yaml to /tf/avm/config/config.yaml.*


#### **Bug Fixes:**
- *No Bug Fixes added in this release.*

---

### **Version 0.0.14 (17 Feb 2025)**
#### **Compatibility:**
- **AAF AVM SDE:** `gccstarterkit/gccstarterkit-avm-sde:0.2`
- **Azurerm:** Version 3.85
- **AAF:** Version 0.0.5

#### **New Features:**
- add multiple resouce names for app service, container app, container instance, vm
- add container as Publishing model for app service and linux function app

#### **Enhancements:**
- *No Enhancements added in this release.*

#### **Bug Fixes:**
- *No Bug Fixes added in this release.*

---

### **Version 0.0.13 (14 Feb 2025)**
#### **Compatibility:**
- **AAF AVM SDE:** `gccstarterkit/gccstarterkit-avm-sde:0.2`
- **Azurerm:** Version 3.85
- **AAF:** Version 0.0.5

#### **New Features:**
- Added Solution Accelerator Container App Intranet
- Added Solution Accelerator VMSS Linux
- Added Solution Accelerator VMSS Windows
- Added Single Resource Group feature
- Added Suffix for naming standard
- Added install.sh single deployment script

#### **Enhancements:**
- Add parameters for var.subnet_name for all solution accelerators

#### **Bug Fixes:**
- fixed issue with long window name
- set lower case for resource group for vm

---

### **Version 0.0.12 (08 Feb 2025)**
#### **Compatibility:**
- **AAF AVM SDE:** `gccstarterkit/gccstarterkit-avm-sde:0.2`
- **Azurerm:** Version 3.85
- **AAF:** Version 0.0.5

#### **New Features:**
- Added Solution Accelerator Container App 

#### **Enhancements:**
- *No Enhancements added in this release.*

#### **Bug Fixes:**
- *No Bug Fixes added in this release.*

---

### **Version 0.0.11 (06 Feb 2025)**
#### **Compatibility:**
- **AAF AVM SDE:** `gccstarterkit/gccstarterkit-avm-sde:0.2`
- **Azurerm:** Version 3.85
- **AAF:** Version 0.0.5

#### **New Features:**
- *No features added in this release.*

#### **Enhancements:**
- Updated Redis Cache creation using AVM
- Updated AGW creation using AVM
- Updated ACR creation using AVM 
- Updated Container Instance creation using AVM 

#### **Bug Fixes:**
- *No Bug Fixes added in this release.*

---

### **Version 0.0.10 (24 Oct 2024)**
#### **Compatibility:**
- **AAF AVM SDE:** `gccstarterkit/gccstarterkit-avm-sde:0.2`
- **Azurerm:** Version 3.85
- **AAF:** Version 0.0.5

#### **New Features:**
- Added Solution Accelerator IoT Hub.
- Added Solution Accelerator Event Hubs.
- Added Solution Accelerator Data Explorer.
- Added Solution Accelerator Stream Analytics.
- Added Solution Accelerator Azure Frontdoor.

#### **Enhancements:**
- *No Enhancements added in this release.*

#### **Bug Fixes:**
- *No Bug Fixes added in this release.*

---

### **Version 0.0.9 (09 Sep 2024)**
#### **Compatibility:**
- **AAF AVM SDE:** `gccstarterkit/gccstarterkit-avm-sde:0.2`
- **Azurerm:** Version 3.85
- **AAF:** Version 0.0.5

#### **New Features:**
- *No features added in this release.*

#### **Enhancements:**  
- *No Enhancements added in this release.*

#### **Bug Fixes:**
- Resolved an issue with diagnostic settings on storage accounts to prevent changes upon redeployment.
- Resolved an issue with subnets missing in ingress/egress infra landing zone
- Resolved an issue with key is NoneType when generating NSG config
- Resolved an issue with natgateway unable to find subnets.id in infra landing zone
- Resolved an issue with the diagnostic setting of internet ingress nsg
- Resolved an issue with the subnets not to assign nsg to azurefirewallsubnet

---

### **Version 0.0.8 (July 22, 2024)**
#### **Compatibility:**
- **AAF AVM SDE:** `gccstarterkit/gccstarterkit-avm-sde:0.1`
- **Azurerm:** Version 3.85
- **AAF:** Version 0.0.5

#### **New Features:**
- *No features added in this release.*

#### **Enhancements:**
- Standardized the configuration by moving the `config.yaml` file into the `scripts` folder.

#### **Bug Fixes:**
- Fixed deployment issues with Cosmos DB Mongo.
- Resolved private endpoint issues for App Service APIs.

---

### **Version 0.0.7 (July 19, 2024)**
#### **Compatibility:**
- **AAF AVM SDE:** `gccstarterkit/gccstarterkit-avm-sde:0.1`
- **Azurerm:** Version 3.85
- **AAF:** Version 0.0.5

#### **New Features:**
- *No features added in this release.*

#### **Enhancements:**
- Refactored the network security group (NSG) code for improved maintainability.

#### **Bug Fixes:**
- Addressed an issue where `sed` was unable to flush to disk fast enough during script execution.

---

### **Version 0.0.6 (July 17, 2024)**
#### **Compatibility:**
- **AAF AVM SDE:** `gccstarterkit/gccstarterkit-avm-sde:0.1`
- **Azurerm:** Version 3.85
- **AAF:** Version 0.0.5

#### **New Features:**
- Added logging and backup functionalities for Solution Accelerator App Service.

#### **Enhancements:**
- Updated subnet creation to utilize AVM’s `Azure/avm-res-network-virtualnetwork/azurerm//modules/subnet`.

#### **Bug Fixes:**
- Fixed deployment errors for Cosmos DB Mongo and Cosmos DB SQL.

---

### **Version 0.0.5 (July 10, 2024)**
#### **Compatibility:**
- **AAF AVM SDE:** `gccstarterkit/gccstarterkit-avm-sde:0.1`
- **Azurerm:** Version 3.85
- **AAF:** Version 0.0.4

#### **New Features:**
- Added a launchpad for non-GCC environments, including virtual network creation.
- Introduced Logic App Solution Accelerators.

#### **Enhancements:**
- Removed modules from the starter kit; all non-AVM modules now exist within AAF.
- Enabled the ability to set the `source_image_resource_id` for VM Solution Accelerators.
- Updated the GCC Dev environment to accept variables via `-var` in Terraform plan/apply.
- Renamed `script_launchpad` to `script`.
- Upgraded AVM virtual networks to version 0.2.3.
- Upgraded AVM private DNS zones to version 0.1.2.

#### **Bug Fixes:**
- Fixed KeyVault `resource_id` error for Management VM.

---

### **Version 0.0.4 (June 20, 2024)**
#### **Compatibility:**
- **AAF AVM SDE:** `gccstarterkit/gccstarterkit-avm-sde:0.1`
- **Azurerm:** Version 3.85
- **AAF:** Version 0.0.3

#### **New Features:**
- Added support for intranet egress firewall, ingress AGW, and ingress firewall.

#### **Enhancements:**
- Added global setting tags to all Solution Accelerators and the `0-setup_gcc_dev_env`.
- Set custom module source to `AcceleratorFramew0rk/aaf/azurerm//modules/...`.
- Removed hardcoded virtual network names during the import of Terraform state in the launchpad.
- Removed unused template folders to avoid code duplication.

#### **Bug Fixes:**
- Verified APIM environment to ensure it is set to either Non-Production [Developer1] or Production [Premium] SKU.
- Corrected diagnostics settings for the hub intranet egress Public IP.
- Fixed duplicate `resource_group_name` variable in ingress firewall configurations.

---

### **Version 0.0.3 (June 13, 2024)**
#### **Compatibility:**
- **AAF AVM SDE:** `gccstarterkit/gccstarterkit-avm-sde:0.1`
- **Azurerm:** Version 3.85
- **AAF:** Version 0.0.1

#### **New Features:**
- Enabled standalone deployment for each Solution Accelerator, eliminating dependencies on the `import.sh` script and landing zones.

#### **Enhancements:**
- Updated AVM Bastion Host module to version 0.2.0.
- Added diagnostic settings for the Bastion Host and DevOps Container Instance.
- Introduced standalone deployment for the MSSQL Solution Accelerator.
- Added diagnostic settings for APIM, Search Service, Service Bus, and Storage Account.

#### **Bug Fixes:**
- Fixed NSG configurations for Application Gateway.

---

### **Version 0.0.2 (May 29, 2024)**
#### **Compatibility:**
- **AAF AVM SDE:** `gccstarterkit/gccstarterkit-avm-sde:0.1`
- **Azurerm:** Version 3.85
- **AAF:** Version 0.0.1

#### **New Features:**
- Added modules:
  - API Management
- Introduced Solution Accelerators for:
  - API Management (APIM)

#### **Enhancements:**
- Updated `framework.landingzone` source to `AcceleratorFramew0rk/aaf/azurerm` version 0.0.1.
- Upgraded AVM Virtual Network to version 0.1.4.
- Upgraded AVM Network Security Group to version 0.2.0.
- Converted the GCC Dev environment to use `config.yaml` for VNet name and CIDR settings.
- Added diagnostic settings for the Network Security Group for Application/Platform Landing Zone.

#### **Bug Fixes:**
- Fixed invalid attributes in the Network Security Group output for `resource` and `security_rules`.

---

### **Version 0.0.1 (May 23, 2024)**
#### **Compatibility:**
- **AAF AVM SDE:** `gccstarterkit/gccstarterkit-avm-sde:0.1`
- **Azurerm:** Version 3.85
- **AAF:** Version 0.0.1

#### **New Features:**
- Imported GCCI Terraform state.
- Added Platform Common Service and Application Landing Zones.
- Introduced Solution Accelerators for:
  - AKS
  - SQL Server
  - Container Registry
  - App Service
  - Key Vault
  - Bastion Host
  - VM
  - Container Instance

#### **Enhancements:**
- *No enhancements in this release.*

#### **Bug Fixes:**
- *No bug fixes in this release.*

