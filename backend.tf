/*
terraform {
  backend "s3" {
    encrypt = true
    bucket = "BUCKET_NAME"
    dynamodb_table = "TABLE_NAME"
    key = "terraform.tfstate"
    region = "ap-south-1"
  }
} */
