resource "aws_s3_bucket" "temperature_bucket" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "temperature_bucket_encrypt" {
  bucket = aws_s3_bucket.temperature_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key
    }
  }
}