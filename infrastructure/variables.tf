locals{
    project-name = "mlops-zoomcamp-capstone"
    state-bucket-name = "${local.project-name}-terraform-state"
    state-bucket-kms-alias = "alias/terraform-bucket-key"
    dynamodb-state-lock-table="terraform-state"
}

variable "region" {
  description = "Region for AWS resources. Choose as per your location"
  default     = "eu-central-1" # Frankfurt
  type        = string
}