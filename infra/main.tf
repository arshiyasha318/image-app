# VPC module: provisions networking resources (VPC, subnets, etc.)
module "vpc" {
  source = "./modules/vpc"

  cidr_block            = var.vpc_cidr
  availability_zones    = var.availability_zones
  public_subnet_cidrs   = var.public_subnets
  private_subnet_cidrs  = var.private_subnets
}

# EKS cluster module: provisions EKS control plane only
module "eks_cluster" {
  source            = "./modules/eks"
  cluster_name      = var.cluster_name
  eks_version       = var.eks_version
  cluster_role_arn  = module.iam.eks_cluster_role_arn
  private_subnet_cidrs = module.vpc.private_subnet_ids   # Use subnet IDs, not CIDRs
  public_subnet_cidrs  = module.vpc.public_subnet_ids    # Use subnet IDs, not CIDRs
}

# OIDC module: sets up OIDC provider for IRSA, depends on EKS cluster
module "oidc" {
  source       = "./modules/oidc"
  cluster_name = module.eks_cluster.cluster_name
  depends_on = [module.eks_cluster]
}

# IAM module: creates IAM roles for EKS cluster, nodes, and IRSA, depends on OIDC
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

# EKS node group module: provisions EKS node group, depends on IAM
module "eks_node_group" {
  source            = "./modules/eks_node_group"
  cluster_name      = module.eks_cluster.cluster_name
  node_group_name   = var.node_group_name
  node_role_arn     = module.iam.eks_node_role_arn
  instance_types    = var.instance_types
  desired_size      = var.desired_size
  max_size          = var.max_size
  min_size          = var.min_size
  private_subnet_cidrs = module.vpc.private_subnet_ids   # Use subnet IDs, not CIDRs
  depends_on = [module.iam]
} 


# data "aws_eks_cluster" "cluster" {
#   name = module.eks_cluster.cluster_name
# }

# data "aws_eks_cluster_auth" "cluster" {
#   name = module.eks_cluster.cluster_name
# }

# provider "kubernetes" {
#   alias                  = "eks"
#   host                   = data.aws_eks_cluster.cluster.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.cluster.token

# }

# # ALB Controller module: provisions AWS Load Balancer Controller, depends on IAM and OIDC
# module "alb_controller" {
#   source = "./modules/alb_controller"
#   cluster_name        = module.eks_cluster.cluster_name
#   region              = var.region
#   vpc_id              = module.vpc.vpc_id
#   oidc_provider_arn   = module.oidc.oidc_provider_arn
#   oidc_provider_url   = module.oidc.oidc_provider_url_without_scheme
#   cluster_endpoint    = module.eks_cluster.cluster_endpoint
#   cluster_ca          = module.eks_cluster.certificate_authority 

#   providers = {
#     kubernetes = kubernetes.eks
#   }

#   # depends_on = [ module.iam, module.oidc, module.eks_cluster , module.eks_node_group , module.vpc ]
# }

# Route module: acm & Route53 records, 
module "route" {
  source = "./modules/route"
 
}


#Apply Kubernetes manifests for the application

resource "null_resource" "apply_k8s_manifests" {
  provisioner "local-exec" {
    command = <<EOT
      aws eks update-kubeconfig --region us-east-1 --name ${module.eks_cluster.cluster_name}
      kubectl apply -f ./k8s/
    EOT

    environment = {
      KUBECONFIG = "${pathexpand("~/.kube/config")}"
    }
  }

  # depends_on = [
  #   module.eks_cluster,
  #   module.eks_node_group
  # ]
}
