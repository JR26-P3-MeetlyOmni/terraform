locals {
  frontend_repository_name = "${var.name_prefix}-${var.env}/${var.frontend_repository_suffix}"
  backend_repository_name  = "${var.name_prefix}-${var.env}/${var.backend_repository_suffix}"
}

resource "aws_ecr_repository" "frontend" {
  name                 = local.frontend_repository_name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
}

resource "aws_ecr_repository" "backend" {
  name                 = local.backend_repository_name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
}
