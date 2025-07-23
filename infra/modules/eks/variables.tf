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

# Version of the EKS cluster
variable "eks_version" {
  description = "The version of the EKS cluster"
  type        = string
}

# Desired number of nodes in the node group
variable "desired_size" {
  description = "Desired number of nodes in the node group"
  type        = number
  default     = 1
}

# Minimum number of nodes in the node group
variable "min_size" {
  description = "Minimum number of nodes in the node group"
  type        = number
  default     = 1
}

# Maximum number of nodes in the node group
variable "max_size" {
  description = "Maximum number of nodes in the node group"
  type        = number
  default     = 2
}

# IAM role ARN for the EKS control plane
variable "cluster_role_arn" {  
  description = "The ARN of the IAM role for the EKS cluster"
  type        = string
}

# List of private subnet IDs for the EKS cluster and node group
variable "private_subnet_cidrs" {
  description = "List of private subnet IDs for the EKS cluster and node group"
  type        = list(string)
}

# List of public subnet IDs for the EKS cluster networking
variable "public_subnet_cidrs" {
  description = "List of public subnet IDs for the EKS cluster networking"
  type        = list(string)
}

# IAM role ARN for the EKS node group
variable "node_role_arn" {
  description = "The ARN of the IAM role for the EKS node group"
  type        = string
}