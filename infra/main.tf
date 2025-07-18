module "vpc" {
  source = "./modules/vpc"
 
} 

module "s3" {
  source = "./modules/s3"
  
}

# module "eks" {
#   source = "./modules/eks"

#   cluster_name  = "image-app-cluster"
#   kubernetes_version = "1.29"
#   subnet_ids    = module.vpc.private_subnet_ids
#   eks_role_arn  = module.iam.eks_role_arn
#   fargate_pod_execution_role_arn = module.iam.fargate_pod_execution_role_arn

#   fargate_profiles = {
#       default = {
#         subnet_ids = module.vpc.public_subnet_ids
#         namespace  = "default"
#       }
#     }
#   }

# module "iam" {
#   source        = "./modules/iam"
#   name          = var.name
#   cluster_name  = module.eks.cluster_name
#   oidc_provider = module.eks.oidc_provider
# }

# module "s3" {
#   source        = "./modules/s3"
# }


# module "route53" {
#   source         = "./modules/route53"
#   domain_name    = var.domain_name
#   alb_dns_name   = module.alb_ingress.alb_dns_name
#   hosted_zone_id = var.hosted_zone_id
#   record_name    = var.record_name
#   alb_zone_id    = module.alb_ingress.alb_zone_id
# }
