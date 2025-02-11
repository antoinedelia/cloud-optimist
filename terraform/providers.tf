terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.86.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.3"
    }
  }
}