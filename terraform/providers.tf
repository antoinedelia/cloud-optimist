terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.45.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.0"
    }
  }
}