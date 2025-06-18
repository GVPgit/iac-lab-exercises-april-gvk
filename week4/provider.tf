terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = var.region
  profile = "twbeach"
default_tags {
    tags = {
      ManagedBy = "Terraform"
      Project = var.prefix
      Environment = "Dev"
    }
  }
}
