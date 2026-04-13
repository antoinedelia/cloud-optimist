terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.40.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.8.1"
    }
  }
}