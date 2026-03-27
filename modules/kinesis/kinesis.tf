resource "aws_kinesis_stream" "provisioned_stream" {
  name             = var.stream_name
  shard_count      = 3
  retention_period = 24

  # This block defines the capacity mode
  stream_mode_details {
    stream_mode = "PROVISIONED"
  }
  
  encryption_type = "KMS"
  kms_key_id      = var.key_arn
}