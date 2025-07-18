resource "aws_s3_bucket" "image_store" {
  bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.image_store.id
  block_public_acls   = true
  block_public_policy = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.image_store.id
  versioning_configuration {
    status = "Enabled"
  }
} 
