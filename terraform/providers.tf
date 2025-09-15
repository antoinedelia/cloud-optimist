terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.13.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
}