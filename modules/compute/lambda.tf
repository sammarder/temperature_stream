data "archive_file" "stream_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/extractor.py" # Path to your script
  output_path = "${path.module}/extractor_function_payload.zip"
}

resource "aws_lambda_function" "stream_lambda" {
  filename      = "${path.module}/extractor_function_payload.zip"
  function_name = "extractor"
  role          = var.lambda_role
  handler       = "extractor.lambda_handler" # filename.function_name
  timeout       = 120
  source_code_hash = data.archive_file.stream_lambda_zip.output_base64sha256

  
  runtime = "python3.12"
  
  environment {
    variables = {
      TABLE_NAME = var.dynamo_tablename
    }
  }
}

resource "aws_lambda_event_source_mapping" "kinesis_trigger" {
  event_source_arn  = var.stream_arn
  function_name     = aws_lambda_function.stream_lambda.arn
  
  # Where to start if the mapping is brand new
  # LATEST: Only new data
  # TRIM_HORIZON: Start from the oldest data available in the stream
  starting_position = "LATEST"

  # Performance & Cost Tuning
  batch_size                         = 100 # Records per Lambda trigger
  maximum_batching_window_in_seconds = 10  # Wait up to 10s to fill the batch
  
  # Reliability
  bisect_batch_on_function_error = true
  maximum_retry_attempts         = 3
}