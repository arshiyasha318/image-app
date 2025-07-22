variable "cidr_block" {
    description = "The CIDR block for the VPC"
    type        = string
    
  } 

  variable "availability_zones" {
    description = "List of availability zones to use for the subnets"
    type        = list(string)
   
} 

  variable "public_subnet_cidrs" {
        description = "List of CIDR blocks for public subnets"
        type        = list(string)
       
    } 


    variable "private_subnet_cidrs" {
        description = "List of CIDR blocks for private subnets"
        type        = list(string)
    
       }