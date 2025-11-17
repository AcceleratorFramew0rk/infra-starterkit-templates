** IMPORTANT: 
https://learn.microsoft.com/en-us/answers/questions/1377548/unable-to-enable-encryption-at-host-for-azure-vm
ERROR: message": "Subscription does not enable EncryptionAtHost.
Solution:
go to cloud shell, execute
Register-AzProviderFeature -FeatureName "EncryptionAtHost" -ProviderNamespace "Microsoft.Compute"

### 🔹 Step 1: Navigate to the Terraform Configuration Directory

```bash
cd /tf/avm/templates/landingzone/configuration/2-solution_accelerators/project/aks_avm_ptn
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

# ----------------------------------------------------------------------------------------

# NOTE: SystemNodePoolSubnet required NAT Gateway

# Estimate time: 20 minutes to deploy
system node: 10 minutes
diagnostic setting 20 seconds
user node: 10 minutes

# 04 Jun 2024
# if egress firewall is not deployed, make sure do not create the route table
# Solution - ensure routetable is set correctly or remove it.
<!-- │ Error: creating Kubernetes Cluster (Subscription: "0b5b13b8-0ad7-4552-936f-8fae87e0633f"
│ Resource Group Name: "aoaidev-rg-solution-accelerators-aks"
│ Kubernetes Cluster Name: "aks-aoaidev-aks-ran"): polling after CreateOrUpdate: polling failed: the Azure API returned the following error:
│ 
│ Status: "VMExtensionProvisioningError"
│ Code: ""
│ Message: "Unable to establish outbound connection from agents, please see https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-code-outboundconnfailvmextensionerror and https://aka.ms/aks-required-ports-and-addresses for more information."
│ Activity Id: "" -->

# ** IMPORTANT: ensure subnet has sufficient IPs available for the worker nodes (max count)

# ** IMPORTANT: remove deny all inbound and outbound to test if AKS create failed for SystemNodePoolSubnet and UserNodePoolSubnet NSG

cd /tf/avm/templates/landingzone/configuration/2-solution_accelerators/project/aks_avm_ptn

# Run the Custom Terraform initialization script "terraform-init-custom" at location "/usr/local/bin" to set up the backend and providers
terraform-init-custom

# Generate an execution plan to preview the changes Terraform will make
terraform plan

# Apply the Terraform configuration and automatically approve changes without prompting for confirmation
terraform apply -auto-approve

# ** IMPORTANT
# Add in deny all inbound and outbound after AKS is deployed