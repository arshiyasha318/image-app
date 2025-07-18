resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.eks_role_arn

  version = var.kubernetes_version

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator"]

  kubernetes_network_config {
    service_ipv4_cidr = var.service_ipv4_cidr
  } 

  tags = var.tags
}

resource "aws_eks_fargate_profile" "default" {
  for_each = var.fargate_profiles

  cluster_name           = aws_eks_cluster.this.name
  fargate_profile_name   = each.key
  pod_execution_role_arn = var.fargate_pod_execution_role_arn
  subnet_ids             = each.value["subnet_ids"]

  selector {
    namespace = each.value["namespace"]
  }

  tags = var.tags
}

resource "aws_iam_openid_connect_provider" "eks_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_thumbprint.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

data "tls_certificate" "eks_thumbprint" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}
