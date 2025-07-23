module "vpc" {
  source = "./modules/vpc"

  cidr_block            = var.vpc_cidr
  availability_zones    = var.availability_zones
  public_subnet_cidrs   = var.public_subnets
  private_subnet_cidrs  = var.private_subnets
}

module "oidc" {
  source       = "./modules/oidc"
  cluster_name = var.cluster_name
}

module "iam" {
  source = "./modules/iam"

  s3_bucket_name                 = module.s3.bucket_name
  oidc_provider_arn             = module.oidc.oidc_provider_arn
  oidc_provider_url_without_scheme = module.oidc.oidc_provider_url_without_scheme
}




 module "s3" {
  source       = "./modules/s3"
  bucket_name = var.s3_bucket_name

} 

 module "eks" {
  source          = "./modules/eks"
  cluster_name    = var.cluster_name
  eks_version     = var.eks_version
  cluster_role_arn = module.iam.image-app_role_arn
  instance_types = var.instance_types
  node_group_name = var.node_group_name
  desired_size    = var.desired_size
  max_size        = var.max_size
  min_size        = var.min_size

} 
