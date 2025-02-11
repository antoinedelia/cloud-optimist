terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.14.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
  }
}