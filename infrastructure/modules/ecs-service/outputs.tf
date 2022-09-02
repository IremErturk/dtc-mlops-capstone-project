output "default_vpc_aws_security_group_id" {
  value = aws_security_group.service_security_group.id
}