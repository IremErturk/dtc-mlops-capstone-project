data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

## ecs_task_execution_role: that the Amazon ECS container agent and the Docker daemon can assume.
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.service_name}-ecs_task_execution_role"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
}

resource "aws_iam_policy" "allow_retrieving_secrets_from_parameter_store" {
 name        = "${var.service_name}_AllowRetrievingSecretsFromParameterStore"
 policy = jsonencode({
  Version = "2012-10-17"
  Statement = [
    {
      Effect = "Allow"
      Action = [
        "ssm:GetParameters"
      ]
      Resource = ["*"]
    }
  ]
  })
}
resource "aws_iam_role_policy_attachment" "execution_role_retrieving_secrets_policy" {
  role       = "${aws_iam_role.ecs_task_execution_role.name}"
  policy_arn = "${aws_iam_policy.allow_retrieving_secrets_from_parameter_store.arn}"
}







## ecs_task_role: that allows your Amazon ECS container task to make calls to other AWS services.
resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.service_name}-ecs_task_role"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

resource "aws_iam_policy" "allow_s3_storage" {
 name        = "${var.service_name}_AllowS3Storage"
 policy = jsonencode({
  Version = "2012-10-17"
  Statement = [
    {
      Effect = "Allow"
      Action = [
        "s3:*"
      ]
      Resource = ["*"]
    }
  ]
  })
}
resource "aws_iam_role_policy_attachment" "task_role_s3_access_policy" {
  role       = "${aws_iam_role.ecs_task_role.name}"
  policy_arn = "${aws_iam_policy.allow_s3_storage.arn}"
}

resource "aws_iam_policy" "allow_ecs_tasks" {
 # permissions needed by Prefect to register new task definitions, deregister old ones, and create new flow runs as ECS tasks
 name        = "${var.service_name}_AllowECSTasks"
 policy = jsonencode({
  Version = "2012-10-17"
  Statement = [
    {
      Effect = "Allow"
      Action = [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CreateSecurityGroup",
        "ec2:CreateTags",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeVpcs",
        "ec2:DeleteSecurityGroup",
        "ecs:CreateCluster",
        "ecs:DeleteCluster",
        "ecs:DeregisterTaskDefinition",
        "ecs:DescribeClusters",
        "ecs:DescribeTaskDefinition",
        "ecs:DescribeTasks",
        "ecs:ListAccountSettings",
        "ecs:ListClusters",
        "ecs:ListTaskDefinitions",
        "ecs:RegisterTaskDefinition",
        "ecs:RunTask",
        "ecs:StopTask",
        "iam:PassRole",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:GetLogEvents"
      ]
      Resource = ["*"]
    }
  ]
  })
}

resource "aws_iam_role_policy_attachment" "task_role_ecs_taks_policy" {
  role       = "${aws_iam_role.ecs_task_role.name}"
  policy_arn = "${aws_iam_policy.allow_ecs_tasks.arn}"
}


