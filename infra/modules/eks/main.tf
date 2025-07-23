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

# Output cluster details for use in other modules
output "cluster_name" {
  value = aws_eks_cluster.image-app.name
}
output "endpoint" {
  value = aws_eks_cluster.image-app.endpoint
}
output "certificate_authority" {
  value = aws_eks_cluster.image-app.certificate_authority[0].data
}
