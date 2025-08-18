# EKS Control Plane Role: allows EKS to manage the cluster
resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster-image-app"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "eks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "eks-cluster-role"
  }
}

# Attach EKS cluster policy to control plane role
resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Node Group Role: allows EC2 nodes to join the cluster
resource "aws_iam_role" "eks_nodes" {
  name = "eks-node-group-nodes"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "eks-node-role"
  }
}

# Attach required policies to node group role
resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ECRReadOnly" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# IAM Policy for IRSA (S3 access): allows pods to access S3
resource "aws_iam_policy" "s3_access_policy" {
  name        = "s3-access-policy"
  description = "Allow S3 access for image upload"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:*"]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      }
    ]
  })
}

# Attach S3 access policy to node group role
resource "aws_iam_role_policy_attachment" "s3_attach" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# IRSA Role for Service Account: allows pods to assume this role via OIDC
resource "aws_iam_role" "irsa" {
  name = "irsa-s3-access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = var.oidc_provider_arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${var.oidc_provider_url_without_scheme}:sub" = "system:serviceaccount:s3-access-sa:s3-access-sa"
        }
      }
    }]
  })

  tags = {
    Name = "irsa-s3-access-role"
  }
}

# Attach S3 access policy to IRSA role
resource "aws_iam_role_policy_attachment" "irsa_s3" {
  role       = aws_iam_role.irsa.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}
