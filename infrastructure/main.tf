
# Cluster
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
  default-azs     = local.default-azs
}