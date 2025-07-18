
variable "oidc_provider" {
  description = "The ARN of the OIDC provider"
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}
variable "name" {
  description = "The name of the infrastructure"
  type        = string
}