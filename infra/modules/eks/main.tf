module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.8.4"
  cluster_name    = var.cluster_name
  cluster_version = "1.28"
  subnet_ids      = var.subnet_ids
  vpc_id          = var.vpc_id
  enable_irsa     = true

  eks_managed_node_groups = {
    default = {
      name           = var.node_group_name
      instance_types = var.instance_type
      desired_size   = var.desired_size
      max_size       = var.max_size
      min_size       = var.min_size
    }
  }
}
