# # Bucket for Artifacts
resource "aws_s3_bucket" "artifacts" {
    bucket = "${var.project-name}-artifacts"
}

resource aws_s3_bucket_acl "artifacts-bucket-acl" {
    bucket = aws_s3_bucket.artifacts.id
    acl    = "private"
}

resource aws_s3_bucket_versioning "artifacts-bucket-versioning" {
    bucket = aws_s3_bucket.artifacts.id
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_public_access_block" "artifacts-block" {
    bucket = aws_s3_bucket.artifacts.id
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true

}

# ECS Cluster
resource "aws_ecs_cluster" "cluster" {
  count = local.ecs-enabled
  name = var.project-name
}

# Model Serving Service with ECS and Fargate
module "svc-model-serving" {
  source          = "./modules/ecs-service"
  count           = local.ecs-enabled

  cluster-id      = aws_ecs_cluster.cluster[count.index].id
  service-config  = local.svc-model-serving
  default_azs     = local.default_azs
}

output "svc-model-serving" {  
  value = module.svc-model-serving
}

# Model Serving Service with ECS and Fargate
module "svc-experiment-tracking" {
  source          = "./modules/mlflow-service"
  count           = local.ecs-enabled

  cluster_id      = aws_ecs_cluster.cluster[count.index].id
  service_config  = local.svc-experiment-tracking

  artifact_bucket_arn = aws_s3_bucket.artifacts.arn
  artifact_bucket_id  = aws_s3_bucket.artifacts.id
}