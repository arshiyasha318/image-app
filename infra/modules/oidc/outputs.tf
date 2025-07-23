output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.this.arn
}

output "oidc_provider_url_without_scheme" {
  value = replace(aws_iam_openid_connect_provider.this.url, "https://", "")
}

