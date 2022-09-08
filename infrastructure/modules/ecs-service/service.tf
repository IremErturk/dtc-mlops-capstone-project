# Task Definition
resource "aws_ecs_task_definition" "task" {
  family                   = var.service-config.name
  container_definitions    = <<DEFINITION
  [
    {
      "name":"${aws_ecr_repository.repository.name}",
      "image": "${aws_ecr_repository.repository.repository_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": ${var.service-config.container_port},
          "hostPort": ${var.service-config.host_port}
        }
      ],
      "memory": ${var.service-config.task_memory},
      "cpu": ${var.service-config.task_cpu},
      "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "${var.service-config.name}-lg",
            "awslogs-region": "eu-central-1",
            "awslogs-stream-prefix": "${var.service-config.name}"
          }
      } 
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]                            # Stating that we are using ECS Fargate -> alternative can be EC2
  network_mode             = "awsvpc"                               # Using awsvpc as our network mode as this is required for Fargate
  memory                   = var.service-config.task_memory         # Specifying the memory our container requires
  cpu                      = var.service-config.task_cpu            # Specifying the CPU our container requires
  execution_role_arn       = "${aws_iam_role.ecs_task_execution_role.arn}" # that the Amazon ECS container agent and the Docker daemon can assume.
  task_role_arn            = "${aws_iam_role.ecs_task_role.arn}"           # that allows your Amazon ECS container task to make calls to other AWS services.
  depends_on = [aws_ecr_repository.repository, aws_iam_role.ecs_task_execution_role]

}


resource "aws_ecs_service" "service" {
  name            = var.service-config.name
  cluster         = "${var.cluster-id}"
  task_definition = "${aws_ecs_task_definition.task.arn}" # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = var.service-config.svc_desired_count

  load_balancer {
    target_group_arn = "${aws_lb_target_group.target_group.arn}" # Referencing our target group
    container_name   = "${aws_ecs_task_definition.task.family}"
    container_port   = var.service-config.container_port # Specifying the container port
  }

  network_configuration {
    subnets          = var.default_azs
    assign_public_ip = true # Providing our containers with public IPs
    security_groups  = ["${aws_security_group.service_security_group.id}"]
  }
}

resource "aws_security_group" "service_security_group" {
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
  }

  egress {
    from_port   = 0 # Allowing any incoming port
    to_port     = 0 # Allowing any outgoing port
    protocol    = "-1" # Allowing any outgoing protocol
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}