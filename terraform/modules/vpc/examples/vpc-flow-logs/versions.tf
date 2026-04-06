terraform {
  required_version = ">= 0.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 0.1"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 0.1"
    }
  }
}
