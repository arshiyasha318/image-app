terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 5.95.0, < 6.0.0"
    }
  }
}

provider "aws" {
    region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "image-terraform-state-bucket"   
    key            = "eks-image-app/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = true
  }
}

 