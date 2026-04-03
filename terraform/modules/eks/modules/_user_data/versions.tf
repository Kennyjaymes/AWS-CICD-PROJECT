terraform {
  required_version = ">= 1.0"

  required_providers {
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = ">= 0.1"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 0.1"
    }
  }
}
