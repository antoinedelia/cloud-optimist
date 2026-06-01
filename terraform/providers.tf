terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.47.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.0"
    }
  }
}