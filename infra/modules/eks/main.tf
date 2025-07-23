# EKS Cluster resource: creates the EKS control plane
resource "aws_eks_cluster" "image-app" {
  name     = var.cluster_name
  version  = var.eks_version
  role_arn = var.cluster_role_arn

  tags = {
    Name = "image-app-eks-cluster"
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Configure networking for the EKS cluster
  vpc_config {
    subnet_ids = concat(var.private_subnet_cidrs, var.public_subnet_cidrs) # Use both private and public subnets
  }
}

# EKS Node Group: provisions worker nodes for the cluster
resource "aws_eks_node_group" "private-nodes" {
  cluster_name    = aws_eks_cluster.image-app.name
  node_group_name = var.node_group_name
  node_role_arn   = var.node_role_arn

  # Place nodes in private subnets for security
  subnet_ids = var.private_subnet_cidrs

  capacity_type  = "ON_DEMAND" # Use on-demand EC2 instances
  instance_types = var.instance_types

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable = 1 # Allow only one node unavailable during updates
  }

  labels = {
    node = "kubenode02"
  }
}
