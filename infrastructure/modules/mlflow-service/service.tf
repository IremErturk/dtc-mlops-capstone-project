resource "random_password" "mlflow_password" {
  length           = 16
  special          = false
  /* override_special = "_%@" */
}

# Task Definition
resource "aws_ecs_task_definition" "task" {
  family                   = var.service_config.name
  container_definitions = jsonencode([
    {
      name = aws_ecr_repository.repository.name,
      image = aws_ecr_repository.repository.repository_url,
      essential = true,
      environment = [
        {name = "MLFLOW_ARTIFACT_URI", value = "${var.artifact_bucket_id}"}, # ARN ?
        {name = "MLFLOW_DB_DIALECT", value = "postgresql"},
        {name = "MLFLOW_DB_USERNAME", value = "${aws_rds_cluster.mlflow_backend_store.master_username}"},
        {name = "MLFLOW_DB_HOST", value = "${aws_rds_cluster.mlflow_backend_store.endpoint}"},
        {name = "MLFLOW_DB_PORT", value = tostring(aws_rds_cluster.mlflow_backend_store.port)},
        {name = "MLFLOW_DB_DATABASE", value = "${aws_rds_cluster.mlflow_backend_store.database_name}"},
        {name = "MLFLOW_TRACKING_USERNAME", value = "${var.mlflow_username}"},
        {name = "MLFLOW_SQLALCHEMYSTORE_POOL_CLASS", value= "NullPool"}
      ],
      portMappings = [
        {
          containerPort = var.service_config.container_port,
          hostPort = var.service_config.host_port
        }
      ],
      secrets = [
        {name = "MLFLOW_DB_PASSWORD", valueFrom = random_password.mlflow_backend_store.result},
        {name = "MLFLOW_TRACKING_PASSWORD", valueFrom = random_password.mlflow_password.result}
      ],
      memory = var.service_config.task_memory,
      cpu = var.service_config.task_cpu
    }
  ])
  requires_compatibilities = ["FARGATE"]                            # Stating that we are using ECS Fargate -> alternative can be EC2
  network_mode             = "awsvpc"                               # Using awsvpc as our network mode as this is required for Fargate
  memory                   = var.service_config.task_memory         # Specifying the memory our container requires
  cpu                      = var.service_config.task_cpu            # Specifying the CPU our container requires
  execution_role_arn       = "${aws_iam_role.ecs_task_execution_role.arn}"

  depends_on = [aws_ecr_repository.repository, aws_iam_role.ecs_task_execution_role]

}


resource "aws_ecs_service" "service" {
  name            = var.service_config.name
  cluster         = "${var.cluster_id}"
  task_definition = "${aws_ecs_task_definition.task.arn}" # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = var.service_config.svc_desired_count

  load_balancer {
    target_group_arn = "${aws_lb_target_group.target_group.arn}" # Referencing our target group
    container_name   = "${aws_ecs_task_definition.task.family}"
    container_port   = var.service_config.container_port # Specifying the container port
  }

  network_configuration {
    subnets          = [for subnet in aws_subnet.mlflow_public_subnet : subnet.id]
    assign_public_ip = true # Providing our containers with public IPs
    security_groups  = local.create_dedicated_vpc ? [aws_security_group.mlflow_server_sg.0.id] : var.vpc_security_group_ids
  }
}

resource "aws_security_group" "mlflow_server_sg" {
  count       = local.create_dedicated_vpc ? 1 : 0
  name        = "${var.service_config.name}-sg"
  description = "Allow access to ${var.service_config.name}-rds from VPC Connector."
  vpc_id      = local.vpc_id

  ingress {
    description = "Access to ${var.service_config.name}-rds from VPC Connector."
    from_port   = local.db_port
    to_port     = local.db_port
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}