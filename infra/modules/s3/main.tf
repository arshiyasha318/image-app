# S3 bucket for image uploads
resource "aws_s3_bucket" "image_upload" {
  bucket = var.bucket_name
  force_destroy = true # Allows bucket to be destroyed even if not empty

  tags = {
    Name = var.bucket_name
  }
}

# Block all public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.image_upload.id
  block_public_acls   = true
  block_public_policy = true
  restrict_public_buckets = true
}

# Enable versioning on the S3 bucket for data protection
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.image_upload.id
  versioning_configuration {
    status = "Enabled"
  }
} 

