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
  name               = "${var.service-config.name}-ecs_task_execution_role"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = "${aws_iam_role.ecs_task_execution_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# TODO: task_execution_role should contain AllowRetrievingSecretsFromParameterStore


## ecs_task_role: that allows your Amazon ECS container task to make calls to other AWS services.
resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.service-config.name}-ecs_task_role"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

resource "aws_iam_policy" "s3_read_only_policy" {
 name        = "${var.service-config.name}-s3"
 policy = jsonencode({
  Version = "2012-10-17"
  Statement = [
    {
      Effect = "Allow"
      Action = [
        "s3:ListBucket",
        "s3:HeadBucket",
      ]
      Resource = "*"
    },
    {
      Effect = "Allow"
      Action = [
        "s3:ListBucketMultipartUploads",
        "s3:GetBucketTagging",
        "s3:GetObjectVersionTagging",
        "s3:ReplicateTags",
        "s3:PutObjectVersionTagging",
        "s3:ListMultipartUploadParts",
        "s3:PutObject",
        "s3:GetObject",
        "s3:GetObjectAcl",
        "s3:GetObject",
        "s3:AbortMultipartUpload",
        "s3:PutBucketTagging",
        "s3:GetObjectVersionAcl",
        "s3:GetObjectTagging",
        "s3:PutObjectTagging",
        "s3:GetObjectVersion",
      ]
      Resource = [ "*" ]
    },
  ]
  })
}

resource "aws_iam_role_policy_attachment" "task_role_s3_policy" {
  role       = "${aws_iam_role.ecs_task_role.name}"
  policy_arn = "${aws_iam_policy.s3_read_only_policy.arn}"
}