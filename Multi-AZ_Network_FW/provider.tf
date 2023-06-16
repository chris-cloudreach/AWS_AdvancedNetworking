terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.2.0"
    }
  }
}

# AWS PROVIDER - EU-WEST-1
provider "aws" {
  region = "eu-west-1"
}


# provider "aws" {
#   alias = "virginia"
#   region = "us-east-1"
# }
