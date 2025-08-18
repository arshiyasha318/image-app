output "cluster_name" {
  value = aws_eks_cluster.image-app.name
}
output "endpoint" {
  value = aws_eks_cluster.image-app.endpoint
}
output "certificate_authority" {
  value = aws_eks_cluster.image-app.certificate_authority[0].data
}

output "cluster_endpoint" {
  value = aws_eks_cluster.image-app.endpoint
}

