variable "eks_version" {
  description = "The version of the EKS cluster"
  type        = string
  
} 

variable "region" {
  description = "The AWS region where the EKS cluster will be created"
  type        = string
 
  
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  
} 

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  
} 

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  
} 


variable "availability_zones" {
  description = "List of availability zones for the EKS cluster"
  type        = list(string)
  
} 

variable "s3_bucket_name" {
  description = "The name of the S3 bucket for image uploads"
  type        = string
  
} 

variable "image_app_role_arn" {
  description = "The ARN of the IAM role for the EKS cluster"
  type        = string
  
} 

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

