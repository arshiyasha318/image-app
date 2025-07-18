variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.10.0.0/16"
}
variable "public_subnet_cidrs" {
    description = "List of CIDR blocks for public subnets"
    type        = string
    default     = "10.10.1.0/24"
}
variable "private_subnet_cidrs" {
    description = "List of CIDR blocks for private subnets"
    type        = string
    default     = "10.10.2.0/24"
}
variable "s3_bucket_name" {
  description = "Name of the S3 bucket for storing images"
  type        = string
  default     = "image-store-bucket"
} 

variable "name" {
  description = "Name prefix for resources"
  type        = string
  default     = "image-app"
  
} 

variable "image-vpc" {
  description = "VPC ID for the image application"
  type        = string
    default     = "image-app-vpc"  
  
} 

variable "subnet_public" {
  description = "Public subnet IDs for the image application"
  type        = string
  default     = "image-app-public-subnet"
  
} 

variable "subnet_private" {
  description = "Private subnet IDs for the image application"
  type        = string
  default     = "image-app-private-subnet"
} 

variable "Route-table" {
    description = "Route table ID for the image application"
  type        = string
  default     = "image-app-route-table"
} 

variable "internet_gateway" {
  description = "Internet Gateway ID for the image application"
  type        = string
  default     = "image-app-internet-gateway"
} 

