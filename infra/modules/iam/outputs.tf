# Output the EKS control plane IAM role ARN
output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster.arn
}

# Output the EKS node group IAM role ARN
output "eks_node_role_arn" {
  value = aws_iam_role.eks_nodes.arn
}

# Output the IRSA IAM role ARN for service account
output "irsa_role_arn" {
  value = aws_iam_role.irsa.arn
}


