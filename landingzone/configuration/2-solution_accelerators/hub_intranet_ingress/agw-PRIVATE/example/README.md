# ------------------------------------------------------------------
# Deploy Azure Resource using -var-file option
# ------------------------------------------------------------------

```bash

cd /tf/avm/templates/landingzone/configuration/2-solution_accelerators/hub_intranet_ingress/agw
tfd apply -var-file=./example/terraform.tfvars

```