terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 0.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 0.1"
    }
  }
}
