terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Use a compatible version range for the AWS provider
    }
  }
}

# Configure the AWS provider
provider "aws" {
  region = var.aws_region # Region is now a variable
}
