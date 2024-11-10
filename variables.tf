#region
variable "region" {
  description = "Region to build this setup"
  type        = string
}

#vpc
variable "vpc_cidr" {
  description = "CIDR for Main VPC"
  default     = "10.0.0.0/16"
}

#public_subnet
variable "public_subnet" {
  description = "CIDR for public subnet"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

#private_subnet
variable "private_subnet" {
  description = "CIDR for private subnet"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

#instance type
variable "instance_type" {
  description = "instance type of launch template"
  type        = string
  default     = "t2.micro"
}

#loadbalancer
variable "app_load_balancer_name" {
  description = "load balancer name"
  type        = string
  default     = "app-load-balancer"
}

variable "app_lb_listener_port" {
  description = "Listener Port"
  type = number
  default = 80
}

#rds
variable "rds_identifier_name" {
  description = "rds identifier name"
  type        = string
}

variable "rds_db_name" {
  description = "DB name"
  type = string
}

variable "rds_username" {
  description = "rds username"
  type        = string
}

variable "rds_password" {
  description = "rds password"
  type        = string
}

variable "key_pair" {
  description = "Key pair to connect with your instance if you want"
  type = string
  default = "ap-south-1"
}