# Name of the EKS cluster for which to create the OIDC provider
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}