variable "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  type        = string
}

variable "oidc_provider_url_without_scheme" {
  description = "OIDC provider URL without https://"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name for IRSA access"
  type        = string
}
