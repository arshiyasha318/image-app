variable "instance_types" {
  description = "Instance types for EKS node group"
  type        = list(string)
  default     = ["t3.medium"]
}
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "availability_zones" {
  description = "Availability zones to deploy resources"
  type        = list(string)
  default     = ["us-east-1a"]
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "node_group_name" {
  description = "EKS node group name"
  type        = string
}

variable "desired_size" {
  description = "Desired node group size"
  type        = number
}

variable "max_size" {
  description = "Maximum node group size"
  type        = number
}

variable "min_size" {
  description = "Minimum node group size"
  type        = number
}

# variable "instance_types" {
#   description = "Instance types for EKS worker nodes"
#   type        = string

# }

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for image uploads"
  type        = string
}


