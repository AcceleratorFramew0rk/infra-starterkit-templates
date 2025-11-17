### 🔹 Step 1: Navigate to the Terraform Configuration Directory

```bash
cd /tf/avm/templates/landingzone/configuration/2-solution_accelerators/project/app_service
```
### 🔹 Step 2: Run the Custom Terraform Script (`tfexe`) to Initialize and Apply

```bash
tfd apply
```

**Explanation:**

* `tfexe` is a custom wrapper script or executable (located at `/usr/local/bin/tfexe`) designed to manage Terraform commands in a standardized or automated way.
* Running `tfd apply` performs several behind-the-scenes steps, including:

  1. **Backend Initialization**: It sets up the remote backend (such as Azure Storage Account) to store Terraform state securely.
  2. **Validation & Planning** *(optional)*: It validate your configuration and optionally create a plan.
  3. **Apply Execution**: Finally, it applies the Terraform configuration to create or update resources in Azure.

> This custom script abstracts complexity, enforces consistency, and apply terraform specific logic, such as injecting environment variables, setting backends dynamically, or handling module paths.

---

# Linux ASP with one app service "web" and Publishing model = Container
# -----------------------------------------------------------------------------------

# Navigate to the working directory where the Terraform configuration files are located
cd /tf/avm/templates/landingzone/configuration/2-solution_accelerators/project/app_service

linux_fx_version="DOCKER|nginx"
resource_names='["web"]'

# Run the Custom Terraform initialization script "terraform-init-custom" at location "/usr/local/bin" to set up the backend and providers
terraform-init-custom

# Generate an execution plan to preview the changes Terraform will make
terraform plan\
-var="linux_fx_version=${linux_fx_version}"  \
-var="resource_names=${resource_names}" 

# Apply the Terraform configuration and automatically approve changes without prompting for confirmation
terraform apply -auto-approve\
-var="linux_fx_version=${linux_fx_version}"  \
-var="resource_names=${resource_names}" 

# Linux ASP with two app service "web" and "api" in WebIntranetSubnet and AppServiceIntranetSubnet
# -----------------------------------------------------------------------------------

# Navigate to the working directory where the Terraform configuration files are located
cd /tf/avm/templates/landingzone/configuration/2-solution_accelerators/project/app_service

# Run the Custom Terraform initialization script "terraform-init-custom" at location "/usr/local/bin" to set up the backend and providers
terraform-init-custom

# Generate an execution plan to preview the changes Terraform will make
terraform plan\
-var="subnet_name=AppServiceIntranetSubnet" \
-var="ingress_subnet_name=WebIntranetSubnet"

# Apply the Terraform configuration and automatically approve changes without prompting for confirmation
terraform apply -auto-approve\
-var="subnet_name=AppServiceIntranetSubnet" \
-var="ingress_subnet_name=WebIntranetSubnet"


# Windows ASP with two app service "web" and "api"
# -----------------------------------------------------------------------------------

# Navigate to the working directory where the Terraform configuration files are located
cd /tf/avm/templates/landingzone/configuration/2-solution_accelerators/project/app_service

# Run the Custom Terraform initialization script "terraform-init-custom" at location "/usr/local/bin" to set up the backend and providers
terraform-init-custom

# Generate an execution plan to preview the changes Terraform will make
terraform plan \
-var="kind=Windows" \
-var="dotnet_framework_version=v6.0" 

# Apply the Terraform configuration and automatically approve changes without prompting for confirmation
terraform apply -auto-approve \
-var="kind=Windows" \
-var="dotnet_framework_version=v6.0" 

