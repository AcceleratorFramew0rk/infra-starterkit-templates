cd /tf/avm/templates/0-setup_subscription_law

# ** IMPORTANT: if required, modify config.yaml file to determine the vnets name and cidr ranage you want to deploy. 

terraform init -reconfigure
terraform plan
terraform apply -auto-approve

# to continue, goto launchpad folder and follow the steps in README.md

cd /tf/avm/templates/landingzone/configuration/0-launchpad/launchpad_agency_managed_vnet

