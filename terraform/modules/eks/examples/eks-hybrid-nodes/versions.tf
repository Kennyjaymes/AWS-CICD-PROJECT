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
    http = {
      source  = "hashicorp/http"
      version = ">= 0.1"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 0.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 0.1"
    }
  }
}
