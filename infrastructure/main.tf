# Cloud Composer Environment
module "ecs-configuration" {
  source          = "./modules/ecs-fargate"
  count           = local.ecs-enabled
  cluster-name    = local.project-name
  service-configs = [local.model-serving-svc]
}