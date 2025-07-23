# Data source to fetch EKS cluster details by name
data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

# Data source to fetch EKS cluster authentication details
data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

# Data source to fetch the TLS certificate and compute the SHA-1 thumbprint for the OIDC issuer
# This is required for the thumbprint_list in the OIDC provider resource
# Requires the tls provider (add to required_providers if not present)
data "tls_certificate" "oidc_thumbprint" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# OIDC provider resource for enabling IRSA (IAM Roles for Service Accounts)
resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc_thumbprint.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.this.identity[0].oidc[0].issuer

  tags = {
    Name = "oidc-provider"
  }
}
