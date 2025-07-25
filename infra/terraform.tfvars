# terraform.tfvars: Set values for root module variables for this environment
# Adjust these values as needed for your deployment
vpc_cidr           = "10.10.0.0/16"
public_subnets     = ["10.10.1.0/24", "10.10.3.0/24"]
private_subnets    = ["10.10.2.0/24", "10.10.4.0/24"]
availability_zones = ["us-east-1a", "us-east-1b"]
cluster_name       = "image-app"
region = "us-east-1"
eks_version = "1.32"
desired_size       = 1
max_size           = 1
min_size           = 1
node_group_name    = "image-node-group"
instance_types     = ["t3.medium"]
s3_bucket_name     = "image-upload-bucket-dev-20250719"