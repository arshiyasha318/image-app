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
# Enable CROS for the S3 bucket to allow cross-origin requests
resource "aws_s3_bucket_cors_configuration" "cors" {
  bucket = aws_s3_bucket.image_upload.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST", "PUT", "DELETE", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag", "x-amz-request-id", "x-amz-id-2"]
    max_age_seconds = 3000
  }
}

