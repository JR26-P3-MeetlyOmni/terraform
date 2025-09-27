output "alb_frontend_sg_id" {
  value = aws_security_group.alb_frontend.id
}

output "alb_backend_sg_id" {
  value = aws_security_group.alb_backend.id
}

output "ecs_frontend_sg_id" {
  value = aws_security_group.ecs_frontend.id
}

output "ecs_backend_sg_id" {
  value = aws_security_group.ecs_backend.id
}
