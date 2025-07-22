# role for eks cluster
resource "aws_iam_role" "image-app" {
  name = "eks-cluster-image-app"
  tags = {
    tag-key = "eks-cluster-image-app"
  }

  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "eks.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
POLICY
}



resource "aws_iam_role_policy_attachment" "image-app-AmazonEKSClusterPolicy" {
  role       = aws_iam_role.image-app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}



# role for nodegroup

resource "aws_iam_role" "nodes" {
  name = "eks-node-group-nodes"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# IAM policy attachment to nodegroup

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}



# IAM role for the s3 bucket access

resource "aws_iam_policy" "s3_access" {
  name        = "s3-access-policy"
  description = "Allow pods to access S3 bucket"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = "arn:aws:s3:::image-app-bucket-tf-dev/*"
      }
    ]
  })
}


resource "aws_iam_role" "irsa" {
  name = "irsa-s3-access"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "${module.oidc.this.arn}"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${module.iam.oidc_provider_url_without_scheme}:sub" = "system:serviceaccount:default:s3-access-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "irsa_s3" {
  role       = aws_iam_role.irsa.name
  policy_arn = aws_iam_policy.s3_access.arn
}



