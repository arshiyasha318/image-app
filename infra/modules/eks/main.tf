module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.37.2"
  cluster_name    = var.cluster_name
  cluster_version = "1.32"
  subnet_ids      = var.subnet_ids
  vpc_id          = var.vpc_id
  # instance_types = ["t3.medium"] # Uncomment if you want to set a default
  enable_irsa     = true

  eks_managed_node_groups = {
    default = {
      name           = var.node_group_name
      instance_type = var.instance_types
      desired_size   = var.desired_size
      max_size       = var.max_size
      min_size       = var.min_size
    }
  }
}
