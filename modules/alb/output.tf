output "lb_arn" {
  value = aws_lb.this.arn
}

output "lb_dns_name" {
  value = aws_lb.this.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.this.arn
}

output "listener_http_arn" {
  value = aws_lb_listener.http.arn
}

output "listener_https_arn" {
  value = try(aws_lb_listener.https[0].arn, null)
}

