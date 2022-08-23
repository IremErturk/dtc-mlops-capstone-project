terraform {
    backend "s3" {
        bucket         = "mlops-zoomcamp-capstone-terraform-state" # local.state-bucket-name
        key            = "state/terraform.tfstate"
        region         = "eu-central-1" # var.region
        encrypt        = true
        kms_key_id     = "alias/terraform-bucket-key" #local.state-bucket-kms-alias
        dynamodb_table = "terraform-state" #dynamodb-state-lock-table
    }
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 4.0"
        }
    }
}

# Configure the AWS Provider
provider "aws" {
    region = var.region
}