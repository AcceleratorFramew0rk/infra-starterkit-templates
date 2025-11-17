# Linux ASP with two app web and api
# -----------------------------------------------------------------------------------
### 🔹 Step 1: Navigate to the Terraform Configuration Directory

```bash
cd /tf/avm/templates/landingzone/configuration/2-solution_accelerators/project/container_app
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

# Linux ASP with one app "web" 
# -----------------------------------------------------------------------------------

# Navigate to the working directory where the Terraform configuration files are located
cd /tf/avm/templates/landingzone/configuration/2-solution_accelerators/project/container_app

resource_names='["web"]'

# Run the Custom Terraform initialization script "terraform-init-custom" at location "/usr/local/bin" to set up the backend and providers
terraform-init-custom

# Generate an execution plan to preview the changes Terraform will make
terraform plan\
-var="resource_names=${appservice_name}" 

# Apply the Terraform configuration and automatically approve changes without prompting for confirmation
terraform apply -auto-approve\
-var="resource_names=${appservice_name}" 


# Linux ASP with two app "web" and "api" in WebIntranetSubnet and ContainerAppIntranetSubnet
# -----------------------------------------------------------------------------------

# Navigate to the working directory where the Terraform configuration files are located
cd /tf/avm/templates/landingzone/configuration/2-solution_accelerators/project/container_app

# Run the Custom Terraform initialization script "terraform-init-custom" at location "/usr/local/bin" to set up the backend and providers
terraform-init-custom

# Generate an execution plan to preview the changes Terraform will make
terraform plan\
-var="subnet_name=ContainerAppIntranetSubnet" \
-var="ingress_subnet_name=WebIntranetSubnet" 

# Apply the Terraform configuration and automatically approve changes without prompting for confirmation
terraform apply -auto-approve\
-var="subnet_name=ContainerAppIntranetSubnet" \
-var="ingress_subnet_name=WebIntranetSubnet" 
