output "lambda_role" {
  description = "lambda permissions"
  value = aws_iam_role.lambda_role.arn
}