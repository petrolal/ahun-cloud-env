resource "aws_iam_role" "lambda_role" {
  name = "${var.lambda_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "this" {
  function_name = var.lambda_name
  runtime       = "python3.12"
  handler       = "monthly_birthdays_notifier.lambda_handler"
  role          = aws_iam_role.lambda_role.arn

  s3_bucket = var.s3_bucket
  s3_key    = var.s3_key

  memory_size = 128
  timeout     = 10

  environment {
    variables = {
      SPREADSHEET_ID          = var.spreadsheet_id
      WORKSHEET_NAME          = var.worksheet_name
      NAME_COLUMN             = var.name_column
      DATE_COLUMN             = var.date_column
      TELEGRAM_TOKEN          = var.telegram_token
      CHAT_ID                 = var.chat_id
      GOOGLE_CREDENTIALS_JSON = var.google_credentials_json
    }
  }
}

resource "aws_cloudwatch_event_rule" "monthly" {
  name                = "${var.lambda_name}-schedule"
  schedule_expression = "cron(0 12 1 * ? *)"
}

resource "aws_cloudwatch_event_target" "target" {
  rule      = aws_cloudwatch_event_rule.monthly.name
  target_id = "lambda"
  arn       = aws_lambda_function.this.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.monthly.arn
}
