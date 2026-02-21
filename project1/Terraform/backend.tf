terraform {
  backend "s3" {
    bucket         = "kiran-infra-state"
    key            = "project1/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}