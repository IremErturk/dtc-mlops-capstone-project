locals{
    state-bucket-name = "${var.project-name}-terraform-state"
    state-bucket-kms-alias = "alias/terraform-bucket-key"
    dynamodb-state-lock-table="terraform-state"

    default_azs = [ aws_default_subnet.default_subnet_a.id,
                    aws_default_subnet.default_subnet_b.id,
                    aws_default_subnet.default_subnet_c.id ]

    # Caution: Check available memory, cpu combinations from here
    # Reference: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html

    # Fast API Model Serving Service Configuration
    ecs-enabled = 1
    svc-model-serving = { name = "fastapi-app",
                          host_port = 8000,
                          container_port = 8000,
                          task_cpu = 2048,
                          task_memory = 4096,
                          svc_desired_count = 2
                        }

    /* TODO: Both mlflow-service and prefect-service modules are is incomplete state */
    /* The required resources for prefect-agent service is created with cloudformation template  */
    /* svc-experiment-tracking = { name = "mlflow-server",
                                host_port = 5000,
                                container_port = 5000,
                                task_memory = 512,
                                task_cpu = 256,
                                svc_desired_count = 1
                              } */

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