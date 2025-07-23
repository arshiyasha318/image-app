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