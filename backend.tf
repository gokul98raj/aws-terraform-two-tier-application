terraform {
  backend "s3" {
    encrypt = true
    bucket = "lock-test-bucket-tf"
    dynamodb_table = "lock_test_dynamo"
    key = "terraform.tfstate"
    region = "ap-south-1"
  }
}