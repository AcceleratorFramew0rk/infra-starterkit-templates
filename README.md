# virtual machine landing zone project

## goto working directory
```bash
cd /tf/avm/templates
```

## (Optional) Setup GCC Simulator Development Environment
```bash
cd /tf/avm/templates/0-setup_gcc_dev_env

terraform init -reconfigure
terraform plan
terraform apply -auto-approve
```

### Verify content of your /tf/avm/config/config.yaml file and then Execute 
```bash
tfd generate-config
```
### deploy
```bash
azd env set STORAGE_ACCOUNT_NAME xxxxxxxxxxxxxxxxxxxxxx
azd env set RESOURCE_GROUP_NAME xx-xxxxxx-xxx-xxxxxxxx

azd env get-values # list all env variables

azd up
```
