# ECS Cluster
/* resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name
} */


# Task Definition
resource "aws_ecs_task_definition" "task" {
  family                   = var.service_name
  cpu                      = var.container_cpu            # Specifying the CPU our container requires
  memory                   = var.container_memory         # Specifying the memory our container requires
  network_mode             = "awsvpc"                     # Using awsvpc as our network mode as this is required for Fargate
  execution_role_arn       = "${aws_iam_role.ecs_task_execution_role.arn}" # that the Amazon ECS container agent and the Docker daemon can assume.
  task_role_arn            = "${aws_iam_role.ecs_task_role.arn}"           # that allows your Amazon ECS container task to make calls to other AWS services.
  container_definitions    = <<DEFINITION
  [
    {
        "name":"${var.service_name}",
        "image": "${var.service_image}",
        "entryPoint": ["bash","-c"],
        "stopTimeout": 120,
        "command": ["prefect agent start -q ${var.service_name}"],
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "${aws_cloudwatch_log_group.service_cwlg.name}",
            "awslogs-region": "${local.account_region}",
            "awslogs-stream-prefix": "${var.service_name}"
          }
        },
        "secrets": [ 
            {
                "name": "PREFECT_API_URL",
                "valueFrom": "arn:aws:ssm:${local.account_region}:${local.account_id}:parameter/PREFECT_API_URL"
            },
            {
                "name": "PREFECT_API_KEY",
                "valueFrom": "arn:aws:ssm:${local.account_region}:${local.account_id}:parameter/PREFECT_API_KEY"
            }
        ]
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate -> alternative can be EC2
}

# Service
resource "aws_ecs_service" "service" {
  name            = var.service_name
  cluster         = var.cluster_name # "arn:aws:ecs:${local.account_region}:${local.account_id}:cluster/${var.cluster_name}"
  task_definition = "${aws_ecs_task_definition.task.arn}" # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = [ aws_subnet.service_subnet.id ]
    assign_public_ip = true # Providing our containers with public IPs
  }

  depends_on = [ aws_route_table_association.service_subnet_public_route_association, 
                 aws_route.route_to_gw
                 # aws_ecs_cluster.cluster
               ]
}