# Infrastructure as Code

The required AWS resources is defined for being able to deploy services (prefect-agent, mlflow-server*, model-serving) in Cloud.
Therefore infrastructure folder contains different setups and options that helps to apply infrastructure as code practices including Cloudfromation, Terraform and AWS SDK. Eventhough, multiple options are discovered during the development, the main IaC tool is selected as Terraform for majority of resources and Clodformation is used setting up resources specifically required for prefect-agent. 

**Caution::** The infrastructrue module is specifically important if the full cloud deployment cycle of project would like to recreated. If you are interested to test the model_serving and workflow_orchestration capabilities locally. Feel free to skip the infratructure step without an hesitation

----
## Setting Up Infrastructure
---
### Prerequisite Manual Steps & Best Practices

1. Create AWS Console account 
2. Follow Best Practice for IAM users
   1. [Enable Multi-Factor-Authentication(MFA)](https://docs.aws.amazon.com/accounts/latest/reference/root-user-mfa.html)
   2. No Active Access Keys associated with Root IAM Role as desribed [here](https://docs.aws.amazon.com/accounts/latest/reference/best-practices-root-user.html)
   3. [Create IAM User with specific admin rights](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html). Don't forget to write down `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` .
3. Install Terraform as described in [official documentation](https://learn.hashicorp.com/tutorials/terraform/install-cli)

---
### Create AWS Resources from Local Machine

1. Enable the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in your terminal and run terraform commands on the terminal. 

    ```bash
    export AWS_SECRET_ACCESS_KEY = xxxx
    export AWS_ACCESS_KEY_ID = xxxx
    ```

2. Create resources with **terraform**. In this project, the terraform backend storage is selected as s3 bucket, therefore the resource creation actions has to be handled in two steps.
   1. Create State Bucket and Dynamo DB table for colloborative working setup. By using infrastructure code int the `bb17213` git commit hash.
   2. Configure terraform backend as s3-state-bucket and create the remaining resources. By using the master branch.

    Caution :: For each above steps, please run `terraform init` and `terraform apply` commands. 

    ```bash
    # Initialize the terraform 
    terraform init
    ```
    
    ```bash
    # Plan AWS resource creations (optional)
    terraform plan

    # Create AWS resources
    terraform apply
    ```
    
    ```bash
    # Destroy all created resources (optional)
    terraform destroy
    ```
    **Status Quo**: After the step 2, the AWS will create resources for storing the artifacts(s3), running the managed services within ECS cluster, etc

3. In most of the projects, it is more convenient to use one technology for infrastructure creation, however in this project you can create some of the resources (related to `prefect-agent` and `mlflow-server` services) can be created in two different approach (via Terraform and Cloudformation template). In here main focus is the resources related to `prefect-agent`  as `mlflow-server*` module is still in work_in_progress stage of development.
Please follow the next options section for details.

### Options for creating **prefect-agent** 

**3.1. with Terraform**
 
Manually create secrets in AWS SSM for `PREFECT_API_URL` and `PREFECT_API_KEY` in the terminal
```bash
    aws ssm put-parameter --type SecureString --name PREFECT_API_URL --value ${{ secrets.PREFECT_API_URL}} --overwrite
    aws ssm put-parameter --type SecureString --name PREFECT_API_KEY --value ${{ secrets.PREFECT_API_KEY}} --overwrite
```

Update the count value of the `svc_prefect_agent` as `local.ecs-enabled`

Run `terraform apply` to create required resources.

**3.2. with Cloudformation**

Set required secret values to Github Secrets including `PREFECT_API_URL`, `PREFECT_API_KEY` , `AWS_SECRET_ACCESS_KEY` and `AWS_ACCESS_KEY_ID`.

Trigger the GitHub actions workflow named `cloudformation-deploy-mlfow.yml`. Workflow will be using two different cloudformation template and will be creating  the ecr-repository, secrets and ecs-resources for the prefect-agent deployment.

----

## Resources
---
### Supporting Resources

1 Entrypoint of Infrastructure Creation with Terraform
- [Creating your first Terraform infrastructure on AWS](https://medium.com/slalom-technology/creating-your-first-terraform-infrastructure-on-aws-ad986f952951)

2 Best Practices
- [S3 Backend](https://technology.doximity.com/articles/terraform-s3-backend-best-practices)
- [Terraform.Lock.Hcl](https://stackoverflow.com/questions/67963719/should-terraform-lock-hcl-be-included-in-the-gitignore-file)
  
3 Troubleshooting
- [ALB 502 Gateway Error](https://aws.amazon.com/premiumsupport/knowledge-center/elb-alb-troubleshoot-502-errors/)

4 GitHub Actions
- [ECS Deployment with ECR images](https://docs.github.com/en/actions/deployment/deploying-to-your-cloud-provider/deploying-to-amazon-elastic-container-service)
- [GitHub Actions: Push Docker Image to Amazon ECR](https://medium.com/@knoldus/github-actions-push-docker-image-to-amazon-ecr-32ce514c018c)

---
### Further Improvement  

1 Automate the Terraform runs with GitHub Actions and OICD 
  - [GitHub Actions authenticating on AWS without secrets using OIDC with Terraform](https://benoitboure.com/securely-access-your-aws-resources-from-github-actions)
  - [Securely Access Your AWS Resources From Github Actions](https://benoitboure.com/securely-access-your-aws-resources-from-github-actions)


