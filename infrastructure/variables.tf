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