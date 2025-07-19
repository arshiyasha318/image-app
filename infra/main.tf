module "vpc" {
  source              = "./modules/vpc"
  cluster_name        = var.cluster_name
  cidr_block          = var.vpc_cidr
  public_subnets      = var.public_subnets
  private_subnets     = var.private_subnets
  availability_zones  = var.availability_zones
}

module "eks" {
  source            = "./modules/eks"
  cluster_name      = var.cluster_name
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.private_subnet_ids
  node_group_name   = var.node_group_name
  desired_size      = var.desired_size
  max_size          = var.max_size
  min_size          = var.min_size

} 

module "iam" {
  source             = "./modules/iam"
  cluster_name       = var.cluster_name
  oidc_provider_arn  = module.eks.oidc_provider_arn
  s3_bucket_name     = var.s3_bucket_name
}
 

 module "s3" {
  source       = "./modules/s3"
  bucket_name  = var.s3_bucket_name
} 

# module "acm" {
#   source       = "./modules/acm"
#   domain_name  = var.domain_name
#   zone_id      = var.route53_zone_id
# } 

# module "route53" {
#   source         = "./modules/route53"
#   domain_name    = var.domain_name
#   alb_dns_name   = module.eks.alb_dns_name
#   zone_id        = var.route53_zone_id
# }