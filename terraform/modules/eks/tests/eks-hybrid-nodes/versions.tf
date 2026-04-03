terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 1.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 1.0"
    }
  }
}
