resource "aws_iam_role_policy" "combined_lambda_policy" {
  name = "stream_consolidated_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:${var.region}:${var.account_id}:*"
      },
      {
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${var.bucket}/*"
      },
      {
        Action   = ["s3:ListBucket"]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${var.bucket}"
      },
      {
        Action   = ["kms:Decrypt", "kms:GenerateDataKey"]
        Effect   = "Allow"
        Resource = var.key
      },
	  {
        Action   = ["dynamodb:PutItem", "dynamodb:UpdateItem", "dynamodb:BatchWriteItem"]
        Effect   = "Allow"
        Resource = "arn:aws:dynamodb:${var.region}:${var.account_id}:table/${var.table_name}"
      },
      {
        Action   = ["kinesis:GetRecords", "kinesis:GetShardIterator", "kinesis:DescribeStream", "kinesis:ListShards"]
        Effect   = "Allow"
        Resource = "arn:aws:kinesis:${var.region}:${var.account_id}:stream/${var.stream}"
      }
    ]
  })
}