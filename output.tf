output "rds_endpoint" {
  value = aws_db_instance.app_rds.endpoint
}

output "alb_url" {
  value = aws_lb.app_load_balancer.dns_name
}

