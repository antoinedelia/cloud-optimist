terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.65.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.1"
    }
  }
}