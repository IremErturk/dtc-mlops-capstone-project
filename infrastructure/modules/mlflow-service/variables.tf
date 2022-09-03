data "aws_availability_zones" "available" {
  state = "available"
}

locals {

    availability_zones = slice(data.aws_availability_zones.available.names, 0, 3)

    # VPC and subnets
    create_dedicated_vpc    = var.vpc_id == null
    vpc_id                  = local.create_dedicated_vpc ? aws_vpc.mlflow_vpc.0.id : var.vpc_id

    /* # S3 bucket
    create_dedicated_bucket = var.artifact_bucket_id == null
    artifact_bucket_id      = local.create_dedicated_bucket ? module.s3.artifact_bucket_id : var.db_subnet_ids */

    # RDS database
    db_username = "mlflow"
    db_database = "mlflow"
    db_port = 5432
    db_subnet_ids = local.create_dedicated_vpc ? aws_subnet.mlflow_public_subnet.*.id : var.db_subnet_ids
}


variable "cluster_id"{
    description = "AWS ECS Cluster ID"
    type        = string
}

variable "service_config" {
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

variable "artifact_bucket_arn"{
  type = string
}

variable "artifact_bucket_id"{
  type = string
}

variable "vpc_id" {
  type        = string
  description = "(Optional) VPC ID."
  default     = null
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "(Optional) Security group IDs to allow access to the VPC. It will be used only if vpc_id is set."
  default     = null
}

variable "db_subnet_ids" {
  type        = list(string)
  description = "List of subnets where the RDS database will be deployed"
  default     = null
}

variable "aws_region" {
  description = "(Optional) AWS Region."
  type = string
  default = "eu-central-1"
}

variable "mlflow_username" {
  description = "Username used in basic authentication provided by nginx."
  type = string
  default = "mlflow"
}

#### Defaulted Parameters ####

variable "db_skip_final_snapshot" {
  type        = bool
  default     = false
  description = "(Optional) If true, this module will not create a final snapshot of the database before terminating."
}

variable "db_deletion_protection" {
  type        = bool
  default     = false
  description = "(Optional) If true, this module will not delete the database after terminating."
}

variable "db_auto_pause" {
  type        = bool
  default     = true
  description = "If true, the Aurora Serverless cluster will be paused after a given amount of time with no activity. https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless.how-it-works.html#aurora-serverless.how-it-works.pause-resume"
}

variable "db_auto_pause_seconds" {
  type        = number
  default     = 300
  description = "The number of seconds to wait before automatically pausing the Aurora Serverless cluster. This is only used if rds_auto_pause is true."
}

variable "db_min_capacity" {
  type        = number
  default     = 2
  description = "The minimum capacity for the Aurora Serverless cluster. Aurora will scale automatically in this range. See: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless.how-it-works.html"
}

variable "db_max_capacity" {
  type        = number
  default     = 64
  description = "The maximum capacity for the Aurora Serverless cluster. Aurora will scale automatically in this range. See: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless.how-it-works.html"
}


