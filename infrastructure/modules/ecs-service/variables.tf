variable "cluster-id"{
    description = "AWS ECS Cluster ID"
    type        = string
}

variable "service-config" {
  description = "ECS task & service configurations"
  type = object({
    name                = string
    container_port      = number
    host_port           = number
    task_memory         = number
    task_cpu            = number
    svc_desired_count   = number # Desired number of instances running the service/task-definition
    /* svc_azs             = list(string) */
    })
}

variable "default-azs" {
  type = list(string)
}