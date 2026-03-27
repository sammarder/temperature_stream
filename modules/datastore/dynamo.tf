resource "aws_dynamodb_table" "basic_table" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id" # This must match a key in your Python dictionary

  attribute {
    name = "id"
    type = "S" # "S" for String, "N" for Number, "B" for Binary
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.key_arn
  }
}