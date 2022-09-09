variable "cluster_name" {
    description = "AWS ECS Cluster Name"
    type        = string
    default     = "mlops-zoomcamp-capstone"
}

variable "container_cpu" {
    type = number
    default = 512
}

variable "container_memory" {
    type = number
    default = 1024
}

variable "service_name" {
    type = string
    default = "prefect-agent"
}

variable "service_image" {
    type= string
    default = "prefecthq/prefect:2.1.1-python3.10"
}



