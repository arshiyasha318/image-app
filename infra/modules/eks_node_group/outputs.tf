# Output the EKS node group name
output "node_group_name" {
  value = aws_eks_node_group.private-nodes.node_group_name
}

# Output the EKS node group ARN
output "node_group_arn" {
  value = aws_eks_node_group.private-nodes.arn
} 