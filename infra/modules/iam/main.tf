resource "aws_iam_role" "irsa" {
  name = "eks-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_arn, ":oidc-provider/", ":")}:sub" = "system:serviceaccount:default:app-sa"
          }
        }
      }
    ]
  })

  tags = {
    Name = "eks-irsa-role"
  }
}

resource "aws_iam_policy" "s3_access" {
  name        = "S3AccessPolicy"
  description = "Allow S3 access to image bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:*"],
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}/*",
          "arn:aws:s3:::${var.s3_bucket_name}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3" {
  role       = aws_iam_role.irsa.name
  policy_arn = aws_iam_policy.s3_access.arn
}
