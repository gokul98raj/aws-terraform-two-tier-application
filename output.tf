output "rds_endpoint" {
  value = aws_db_instance.app_rds.endpoint
}

output "alb_url" {
  value = aws_lb.app_load_balancer.dns_name
}

output "private_subnet" {
  value = aws_subnet.private_subnet
}

output "public_subnet" {
  value = aws_subnet.public_subnet
}

#subnet_id's

output "private_subnet_ids" {
  value = aws_subnet.private_subnet.*.id
}