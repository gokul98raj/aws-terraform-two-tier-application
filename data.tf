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