locals{
    project-name = "mlops-zoomcamp-capstone"
    state-bucket-name = "${local.project-name}-terraform-state"
    state-bucket-kms-alias = "alias/terraform-bucket-key"
    dynamodb-state-lock-table="terraform-state"

    ecs-enabled = 1
    model-serving-svc = {name ="fastapi-app", host_port=8000, container_port=8000, task_memory=512, task_cpu=256, service_desired_count=2}
}

variable "region" {
  description = "Region for AWS resources. Choose as per your location"
  default     = "eu-central-1" # Frankfurt
  type        = string
}