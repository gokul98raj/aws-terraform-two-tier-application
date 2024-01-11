#network
#vpc
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    name = "main"
  }
}

#subnets
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  count                   = 2
  cidr_block              = element(var.public_subnet, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    name = "public_subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main.id
  count             = 2
  cidr_block        = element(var.private_subnet, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    name = "private_subnet ${count.index + 1}"
  }
}

#internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    name = "main_igw"
  }
}

#route table
resource "aws_route_table" "public_subnet_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    name = "public_subnet_rt"
  }
}

#flow logs for vpc

resource "aws_flow_log" "vpc_logs" {
  log_destination      = aws_s3_bucket.flow_log_bucket.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id
}

resource "aws_s3_bucket" "flow_log_bucket" {
  bucket        = "flow-log-bucket-terraform"
  force_destroy = true

  tags = {
    name = "flow_log_bucket"
  }
}

#server
#security group for loadbalancer
resource "aws_security_group" "load_balancer_security_group" {
  name        = "load_balancer_security_group"
  description = "security group for load balancer to allow https request from users"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "https"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#security group for servers
resource "aws_security_group" "servers_security_group" {
  name        = "servers_security_group"
  description = "security group for servers to allow http request from load balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "http"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_security_group" {
  name        = "rds_security_group"
  description = "security group for rds to allow 3306 from servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.servers_security_group.id}"]
  }

}

#launch template
resource "aws_launch_template" "app_launch_template" {
  name = "app_launch_template"

  block_device_mappings {
    device_name = "dev/sdf"

    ebs {
      volume_size           = 8
      delete_on_termination = true
      encrypted             = true
    }
  }

  image_id      = data.aws_ami.amazon_linux_ami.id
  instance_type = var.instance_type
  key_name      = "ap-south-1"
  monitoring {
    enabled = true
  }

  user_data = base64encode("user-data.sh")
  //user_data = templatefile("user-data.sh", {rds_endpoint = {output = "rds_endpoint" }} )
}

#autoscaling group
resource "aws_autoscaling_group" "app_auto_scaling" {
  name             = "app_auto_scaling"
  min_size         = 2
  max_size         = 5
  desired_capacity = 2
  //vpc_zone_identifier = [aws_subnet.public_subnet.id]
  vpc_zone_identifier = aws_subnet.public_subnet[*].id

  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$latest"
  }

  target_group_arns = [ 
    aws_lb.app_load_balancer.arn
   ]
}

#load balancer
resource "aws_lb" "app_load_balancer" {
  name                       = var.app_load_balancer_name
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.load_balancer_security_group.id]
  subnets                    = aws_subnet.public_subnet[*].id
  enable_deletion_protection = true

}

resource "aws_lb_target_group" "app_lb_target_group" {
  name     = "app-lb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "app_lb_listener" {
  load_balancer_arn = aws_lb.app_load_balancer.arn
  port              = 80
  protocol          = "HTTPS"
  //certificate_arn = ""

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_lb_target_group.arn
  }
}

#rds

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds_subnet_group"
  subnet_ids = aws_subnet.private_subnet[*].id

  tags = {
    name = "rds subnet group"
  }

}

resource "aws_kms_key" "rds_kms_key" {
  description             = "kms key for encrypt rds in rest and transit"
  deletion_window_in_days = 30

  tags = {
    name = "rdskey"
  }
}

resource "aws_db_instance" "app_rds" {
  allocated_storage = 10
  storage_type      = "gp2"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t2.small"
  identifier        = var.rds_identifier_name
  username          = "admin"
  //manage_master_user_password = true
  password = "admin123"
  //deletion_protection = true
  skip_final_snapshot = true


  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name


  backup_retention_period = 3
  backup_window           = "02:00-03:00"
  maintenance_window      = "sat:03:00-sat:04:00"

  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds_kms_key.arn


  multi_az = true

}

#route53
#Certificate manager