# AWS PROVIDER - EU-WEST-1
provider "aws" {
  region = "eu-west-1"
}

# child module provider for spoke 1
provider "aws" {
  alias = "virginia"
  region = "us-east-1"
}

# child module provider for spoke 1
provider "aws" {
  alias = "Ncalifornia"
  region = "us-west-2"
}