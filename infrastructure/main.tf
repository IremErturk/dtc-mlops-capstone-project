# Bucket for  Project Artifacts
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

# Model Serving Service
module "svc-model-serving" {
  source          = "./modules/ecs-service"
  count           = local.ecs-enabled

  cluster-id      = aws_ecs_cluster.cluster[count.index].id
  service-config  = local.svc-model-serving
  default_azs     = local.default_azs
}

# Prefect Workflow Orchestration Agent
/* Prerequsite:
  aws ssm put-parameter --type SecureString --name PREFECT_API_URL --value <PREFECT_API_URL> --overwrite
  aws ssm put-parameter --type SecureString --name PREFECT_API_KEY --value <PREFECT_API_KEY> --overwrite
*/
module "svc_prefect_agent" {
  source          = "./modules/prefect-service"
  count           = 0

  cluster_name    = aws_ecs_cluster.cluster[count.index].id
}
