variable "cluster-name" {
  description = "ECS cluster name"
  default = "mlops-zoomcamp-capstone"
  type        = string
}

variable "service-configs" {
  description = "ECS task & service definitions"
  type = list(object({
    name                      = string
    container_port            = number
    host_port                 = number
    task_memory               = number
    task_cpu                  = number
    service_desired_count     = number
    /* service_avaliability_zones = list(string) */
    }))
}