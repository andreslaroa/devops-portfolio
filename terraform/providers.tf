# Terraform Provider Configuration for AWS
# This tells Terraform to download the necessary plugins to interact with AWS

terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  # Terraform will automatically look for the AWS_ACCESS_KEY_ID and 
  # AWS_SECRET_ACCESS_KEY environment variables we set in the terminal.
  region = "us-east-1"
  profile = "aws-andreslaroa"
}
