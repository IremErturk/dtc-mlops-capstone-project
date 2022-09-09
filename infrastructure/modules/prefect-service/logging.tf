resource "aws_cloudwatch_log_group" "service_cwlg" {
  name = "${var.service_name}"
  retention_in_days = 7
}