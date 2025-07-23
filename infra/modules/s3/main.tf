resource "aws_s3_bucket" "image_upload" {
  bucket = var.bucket_name
  force_destroy = true

  tags = {
    Name = var.bucket_name
  }
}
resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.image_upload.id
  block_public_acls   = true
  block_public_policy = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.image_upload.id
  versioning_configuration {
    status = "Enabled"
  }
} 

