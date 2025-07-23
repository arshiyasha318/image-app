resource "aws_eks_cluster" "image-app" {
  name     = var.cluster_name
  version  = var.eks_version
  role_arn = module.iam.image-app_role_arn

  tags = {
    Name = "image-app-eks-cluster"
  }
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  
  vpc_config {
    subnet_ids = [
      aws_subnet.private-us-east-1a.id,
      aws_subnet.private-us-east-1b.id,
      aws_subnet.public-us-east-1a.id,
      aws_subnet.public-us-east-1b.id
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.image-app-AmazonEKSClusterPolicy
    , aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy
    , aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy
    , aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly
  ]
}


# aws node group 

resource "aws_eks_node_group" "private-nodes" {
  cluster_name    = aws_eks_cluster.image-app.name
  node_group_name = var.node_group_name
  node_role_arn   = module.iam.nodes_role_arn

  subnet_ids = [
    aws_subnet.private-us-east-1a.id,
    aws_subnet.private-us-east-1b.id
  ]

  capacity_type  = "ON_DEMAND"
  instance_types = var.instance_types

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    node = "kubenode02"
  } 
  
 
}


