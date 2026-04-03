terraform {
  required_version = ">= 0.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 0.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 0.1"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.1"
    }
  }
}
