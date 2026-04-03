terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 5.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 5.0"
    }
  }
}
