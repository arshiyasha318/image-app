variable "hosted_zone_id" {
  description = "The Route 53 Hosted Zone ID"
  type        = string
}

variable "record_name" {
  description = "Subdomain (e.g. gallery.example.com)"
  type        = string
}

variable "alb_dns_name" {
  description = "The DNS name of the ALB created by Kubernetes Ingress"
  type        = string
}

variable "alb_zone_id" {
  description = "The Zone ID of the ALB (provided by AWS)"
  type        = string
}
variable "domain_name" {
  description = "The domain name for the application"
  type        = string
}