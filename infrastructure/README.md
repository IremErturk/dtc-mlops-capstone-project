### Setting Up Infrastructure

Prerequisite Manual Steps:
- Create AWS Console account and follow best practices for for root IAM user (such as MFA enabling, no active access keys)
- Create new IAM User & with specific AdministrationAccess rights .. and write down `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
- Install Terraform as described in [official documentation](https://learn.hashicorp.com/tutorials/terraform/install-cli)


#### Create AWS Resources using local terminal
Enable the access_key_id and secret_access_key in your terminal and run terraform commands on the terminal as follows.

Caution::: The creation of AWS resources requires resource creations in two different step.
- Step 1: Create AWS S3 bucket and corresponding resources to setup bucket versioning, encryprition, etc. Use the `bb17213` hash code of
- Step 2: Create remaining resources and also set-up the s3 as terraform backend.


```bash
export AWS_SECRET_ACCESS_KEY = xxxx
export AWS_ACCESS_KEY_ID = xxxx
```

```bash
# Initialize the terraform
terraform init

# Plan AWS resource creations (optional)
terraform plan

# Create AWS resources
terraform apply

# Destroy all created resources (optional)
terraform destroy
```

### AWS best Practices
Best IAM practices for secure AWS accounts
- MFA should be enabled on the Root user IAM
- Root user has no active access keys


### Resources
- **terraform-s3-backend-best-practices**: https://technology.doximity.com/articles/terraform-s3-backend-best-practices
- **should-terraform-lock-hcl-be-included-in-the-gitignore-file**: https://stackoverflow.com/questions/67963719/should-terraform-lock-hcl-be-included-in-the-gitignore-file