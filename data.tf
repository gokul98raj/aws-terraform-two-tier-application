data "aws_availability_zones" "available" {
  state = "available"

}

data "aws_ami" "amazon_linux_ami" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

/*data "aws_iam_policy_document" "get_parameters_source" {
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy_document" "get_parameters_destination" {
  
}*/