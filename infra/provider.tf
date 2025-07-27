# Terraform block specifying required providers
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 5.95.0, < 6.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20" 

  }
}
}

# AWS provider configuration
provider "aws" {
    region = var.region
}

# Configure remote backend for storing Terraform state in S3
terraform {
  backend "s3" {
    bucket         = "image-terraform-state-bucket"   
    key            = "eks-image-app/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = true
  }
}
