terraform {
  required_providers {
    aws = {
      version = "= 4.65.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.3.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }
} 
provider "aws" {
  region = "eu-west-2"
}
