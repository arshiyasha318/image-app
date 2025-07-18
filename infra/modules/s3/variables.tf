variable "s3_bucket_name" {
  description = "Name of the S3 bucket for storing images"
  type        = string
  default     = "image-store-bucket-dev-python"
  } 

variable "region" {
  description = "AWS region for the infrastructure"
  type        = string
  default     = "us-east-1"
}