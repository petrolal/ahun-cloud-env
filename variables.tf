variable "aws_region" {}
variable "bucket_name" {}
variable "lambda_birthday_name" {}
variable "lambda_birthday_zip_key" {}
variable "spreadsheet_birthday_id" {}
variable "worksheet_name" {}
variable "name_column" {}
variable "date_column" {}
variable "telegram_token" { sensitive = true }
variable "chat_id" {}
variable "google_credentials_json" { sensitive = true }
