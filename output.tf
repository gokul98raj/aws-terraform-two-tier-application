output "alb_url" {
  value = "http://${aws_lb.app_load_balancer.dns_name}"
}