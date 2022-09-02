resource "aws_ecr_repository" "repository" {
  name                 = var.service-config.name
  image_tag_mutability = "MUTABLE" # using latest tag therefore required.
  force_delete         = true  # to be able to destroy resources without limitation later

  image_scanning_configuration {
    scan_on_push = true
  }
}