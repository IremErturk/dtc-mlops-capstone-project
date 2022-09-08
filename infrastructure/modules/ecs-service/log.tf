resource "aws_cloudwatch_log_group" "service" {
  name = "${var.service-config.name}-lg"
  retention_in_days = 7
}