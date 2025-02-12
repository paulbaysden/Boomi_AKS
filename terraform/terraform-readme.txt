First install the Azure CLI on your machine:

Windows installer:
https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?pivots=msi
restart command line after install

az --version // to confirm install
az login // login to azure

Then install terraform:
Windows install:
https://developer.hashicorp.com/terraform/install

Once you download it, extract the exe file from the zip file. Then make a new directory called c:\program files\terraform and move the exe there

Then open an admin command prompt and run this command to add it to the PATH:
setx PATH "%PATH%;C:\Program Files\Terraform"

Then restart command prompt again

terraform version // to verify install
terraform init // start terraform services

cd into directory or git branch your terraform scripts are in:

update the variables.tf file on your branch and update "default" values to the names you want for services.

terraform init
terraform plan
terraform apply // deploys your main.tf 

terraform destroy // deletes everything (it will fail on netapp volume, you will have to manually delete it before you run destroy)

