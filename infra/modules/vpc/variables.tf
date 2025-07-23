# The CIDR block for the VPC
variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

# List of availability zones to use for the subnets
variable "availability_zones" {
  description = "List of availability zones to use for the subnets"
  type        = list(string)
}

# List of CIDR blocks for public subnets
variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

# List of CIDR blocks for private subnets
variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}