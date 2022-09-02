locals{

    /* project-name = "mlops-zoomcamp-capstone" */
    state-bucket-name = "${var.project-name}-terraform-state"
    state-bucket-kms-alias = "alias/terraform-bucket-key"
    dynamodb-state-lock-table="terraform-state"

    default_azs = [ aws_default_subnet.default_subnet_a.id,
                    aws_default_subnet.default_subnet_b.id,
                    aws_default_subnet.default_subnet_c.id ]

    # Service Configuration
    ecs-enabled = 1
    svc-model-serving = { name = "fastapi-app",
                          host_port = 8000,
                          container_port = 8000,
                          task_memory = 512,
                          task_cpu = 256,
                          svc_desired_count = 2
                        }

    svc-experiment-tracking = { name = "mlflow-server",
                                host_port = 5000,
                                container_port = 5000,
                                task_memory = 512,
                                task_cpu = 256,
                                svc_desired_count = 1
                              }

    /* svc-workflow_orchestration = { name = "prefect-agent",
                          host_port = 8000,
                          container_port = 8000,
                          task_memory = 512,
                          task_cpu = 256,
                          svc_desired_count = 2
                        } */
}


variable "project-name" {
  description = "Project Name for created resources"
  type = string
  default = "mlops-zoomcamp-capstone"
}

variable "region" {
  description = "Region for AWS resources. Choose as per your location"
  type        = string
  default     = "eu-central-1" # Frankfurt
}