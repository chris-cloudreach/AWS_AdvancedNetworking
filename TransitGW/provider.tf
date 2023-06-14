# AWS PROVIDER - EU-WEST-1
provider "aws" {
  region = "eu-west-1"
}

# using same region for both providers
# becos i dont want to edit alias in code
provider "aws" {
  alias = "virginia"
  region = "us-east-1"
}

# 
provider "aws" {
  alias = "Ncalifornia"
  region = "us-east-1"
}