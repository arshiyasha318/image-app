variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.29"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for EKS"
}

variable "eks_role_arn" {
  type        = string
  description = "IAM role ARN for EKS control plane"
}

variable "fargate_pod_execution_role_arn" {
  type        = string
  description = "IAM role ARN for Fargate pod execution"
}

variable "fargate_profiles" {
  type = map(object({
    subnet_ids = list(string)
    namespace  = string
  }))
  description = "Map of Fargate profiles"
}

variable "service_ipv4_cidr" {
  type        = string
  default     = "172.20.0.0/16"
}

variable "tags" {
  type        = map(string)
  default     = {}
}
