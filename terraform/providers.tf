terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.30.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.8.1"
    }
  }
}