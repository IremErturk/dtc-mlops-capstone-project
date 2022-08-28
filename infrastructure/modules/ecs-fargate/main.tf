# ECR repositories
resource "aws_ecr_repository" "repository" {
  for_each = { for each in var.service-configs : each.name => each }
  name = each.value.name
  force_delete = true
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# Create an Amazon ECS task definition, cluster, and service

# Cluster
resource "aws_ecs_cluster" "cluster" {
  name = var.cluster-name
}

# Task Definition
resource "aws_ecs_task_definition" "task-definition" {
  for_each = { for each in var.service-configs : each.name => each }
  family                   = each.value.name
  container_definitions    = <<DEFINITION
  [
    {
      "name":"${aws_ecr_repository.repository[each.value.name].name}",
      "image": "${aws_ecr_repository.repository[each.value.name].repository_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": ${each.value.container_port},
          "hostPort": ${each.value.host_port}
        }
      ],
      "memory": ${each.value.task_memory},
      "cpu": ${each.value.task_cpu}
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]                    # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"                       # Using awsvpc as our network mode as this is required for Fargate
  memory                   = each.value.task_memory         # Specifying the memory our container requires
  cpu                      = each.value.task_cpu            # Specifying the CPU our container requires
  execution_role_arn       = "${aws_iam_role.ecs_task_execution_role.arn}"

  depends_on = [aws_ecr_repository.repository, aws_iam_role.ecs_task_execution_role]

}

resource "aws_ecs_service" "service" {
  for_each = { for each in var.service-configs : each.name => each }
  name            = each.value.name
  cluster         = "${aws_ecs_cluster.cluster.id}"
  task_definition = "${aws_ecs_task_definition.task-definition[each.value.name].arn}" # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = each.value.service_desired_count

  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
    assign_public_ip = true # Providing our containers with public IPs
  }
}