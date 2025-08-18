# OIDC provider ARN for IRSA (used for service account trust)
variable "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  type        = string
}

# OIDC provider URL without https:// (used for trust policy condition)
variable "oidc_provider_url_without_scheme" {
  description = "OIDC provider URL without https://"
  type        = string
}

# S3 bucket name for IRSA access
variable "s3_bucket_name" {
  description = "S3 bucket name for IRSA access"
  type        = string
}
