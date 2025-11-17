# ------------------------------------------------------------------
# Deploy Azure Resource using -var-file option
# ------------------------------------------------------------------

```bash

cd /tf/avm/templates/landingzone/configuration/2-solution_accelerators/hub_internet_ingress/firewall_ingress
tfd apply -var-file=./example/terraform.tfvars

```