terraform {
  required_version = ">= 1.3.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
  }

  # backend "s3" {
  #   # Replace these with your actual pre-existing S3 bucket and DynamoDB table for storing the state remotely.
  #   bucket         = "my-cicd-terraform-state-bucket"
  #   key            = "aws-cicd-project/terraform.tfstate"
  #   region         = "eu-west-2"
  #   dynamodb_table = "terraform-lock-table"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "EKS-CICD-Pipeline"
      Environment = "Production"
      ManagedBy   = "Terraform"
    }
  }
}
