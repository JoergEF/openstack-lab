# Terraform-based tests

We use terraform to test our Openstack environement.

## ubuntu-1604

Install a dedicated network; ssh key; load a basic ubuntu image and create an instance. 
You must configure an SSH key and the ID of the public network from Openstack you will use.

```
terraform init
terraform plan
terraform apply
terraform destroy # to remove 
```