# Name of the EKS cluster
variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

# Version of the EKS cluster
variable "eks_version" {
  description = "The version of the EKS cluster"
  type        = string
}

# IAM role ARN for the EKS control plane
variable "cluster_role_arn" {  
  description = "The ARN of the IAM role for the EKS cluster"
  type        = string
}

# List of private subnet IDs for the EKS cluster
variable "private_subnet_cidrs" {
  description = "List of private subnet IDs for the EKS cluster"
  type        = list(string)
}

# List of public subnet IDs for the EKS cluster networking
variable "public_subnet_cidrs" {
  description = "List of public subnet IDs for the EKS cluster networking"
  type        = list(string)
}