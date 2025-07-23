# Output the ARN of the OIDC provider for use in IAM module
output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.this.arn
}

# Output the OIDC provider URL without the https:// prefix for use in trust policies
output "oidc_provider_url_without_scheme" {
  value = replace(aws_iam_openid_connect_provider.this.url, "https://", "")
}

