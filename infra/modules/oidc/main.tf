# Data source to fetch EKS cluster details by name
data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

# Data source to fetch EKS cluster authentication details
data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

# OIDC provider resource for enabling IRSA (IAM Roles for Service Accounts)
resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.aws_eks_cluster.this.certificate_authority[0].data]
  url             = data.aws_eks_cluster.this.identity[0].oidc[0].issuer

  tags = {
    Name = "oidc-provider"
  }
}
