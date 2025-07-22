

data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name
}

resource "aws_iam_openid_connect_provider" "this" {
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0afd10df6"]
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}
