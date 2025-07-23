variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}


variable "node_group_name" {
  description = "The name of the EKS node group"
  type        = string
}




variable "instance_types" {
  description = "List of instance types for the EKS node group"
  type        = list(string)
 
  
} 

variable "eks_version" {
  description = "The version of the EKS cluster"
  type        = string
  
} 

variable "desired_size" {
  description = "Desired number of nodes in the node group"
  type        = number
  default     = 1
} 

variable "min_size" {
  description = "Minimum number of nodes in the node group"
  type        = number
  default     = 1
}


variable "max_size" {
  description = "Maximum number of nodes in the node group"
  type        = number
  default     = 2
}

variable "cluster_role_arn" {  
  description = "The ARN of the IAM role for the EKS cluster"
  type        = string
  
}