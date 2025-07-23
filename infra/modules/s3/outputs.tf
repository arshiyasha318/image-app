# Output the name of the created S3 bucket
output "bucket_name" {
  value = aws_s3_bucket.image_upload.bucket
}
