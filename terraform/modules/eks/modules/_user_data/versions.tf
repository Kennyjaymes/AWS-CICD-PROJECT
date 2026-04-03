terraform {
  required_version = ">= 1.0"

  required_providers {
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = ">= 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 5.0"
    }
  }
}
