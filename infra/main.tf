# VPC module: provisions networking resources (VPC, subnets, etc.)
module "vpc" {
  source = "./modules/vpc"

  cidr_block            = var.vpc_cidr
  availability_zones    = var.availability_zones
  public_subnet_cidrs   = var.public_subnets
  private_subnet_cidrs  = var.private_subnets
}

# OIDC module: sets up OIDC provider for IRSA
module "oidc" {
  source       = "./modules/oidc"
  cluster_name = var.cluster_name
}

# IAM module: creates IAM roles for EKS cluster, nodes, and IRSA
module "iam" {
  source = "./modules/iam"

  s3_bucket_name                 = module.s3.bucket_name
  oidc_provider_arn             = module.oidc.oidc_provider_arn
  oidc_provider_url_without_scheme = module.oidc.oidc_provider_url_without_scheme
}

# S3 module: provisions S3 bucket for image storage
module "s3" {
  source       = "./modules/s3"
  bucket_name = var.s3_bucket_name
}

# EKS module: provisions EKS cluster and node group
module "eks" {
  source            = "./modules/eks"
  cluster_name      = var.cluster_name
  eks_version       = var.eks_version
  cluster_role_arn  = module.iam.eks_cluster_role_arn
  instance_types    = var.instance_types
  node_group_name   = var.node_group_name
  desired_size      = var.desired_size
  max_size          = var.max_size
  min_size          = var.min_size

  # Pass required subnet CIDRs to the EKS module
  private_subnet_cidrs = var.private_subnets   # List of private subnet CIDRs for node group placement
  public_subnet_cidrs  = var.public_subnets    # List of public subnet CIDRs for cluster networking

  # Pass the node IAM role ARN for the node group
  node_role_arn        = module.iam.eks_node_role_arn

  # Remove unsupported subnet_ids argument (handled inside the module)
  # depends_on ensures IAM roles are created before EKS
  depends_on = [module.iam]
} 
