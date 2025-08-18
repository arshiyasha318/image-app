# Version of the EKS cluster
variable "eks_version" {
  description = "The version of the EKS cluster"
  type        = string
}

# AWS region for all resources
variable "region" {
  description = "The AWS region where the EKS cluster will be created"
  type        = string
}

# CIDR block for the VPC
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

# List of public subnet CIDR blocks
variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}

# List of private subnet CIDR blocks
variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
}

# List of availability zones for the EKS cluster
variable "availability_zones" {
  description = "List of availability zones for the EKS cluster"
  type        = list(string)
}

# Name of the S3 bucket for image uploads
variable "s3_bucket_name" {
  description = "The name of the S3 bucket for image uploads"
  type        = string
}

# Name of the EKS cluster
variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string 
}

# Name of the EKS node group
variable "node_group_name" {
  description = "The name of the EKS node group"
  type        = string   
}

# List of instance types for the EKS node group
variable "instance_types" {
  description = "List of instance types for the EKS node group"
  type        = list(string)
}

# Desired number of nodes in the EKS node group
variable "desired_size" {
  description = "Desired number of nodes in the EKS node group"
  type        = number
}

# Minimum number of nodes in the EKS node group
variable "min_size" {
  description = "Minimum number of nodes in the EKS node group"
  type        = number
}

# Maximum number of nodes in the EKS node group
variable "max_size" {
  description = "Maximum number of nodes in the EKS node group"
  type        = number
} 

