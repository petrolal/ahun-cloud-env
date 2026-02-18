variable "lambda_name" {
  type = string
}

variable "s3_bucket" {
  type = string
}

variable "s3_key" {
  type = string
}

variable "spreadsheet_id" {
  type = string
}

variable "worksheet_name" {
  type = string
}

variable "name_column" {
  type = string
}

variable "date_column" {
  type = string
}

variable "telegram_token" {
  type      = string
  sensitive = true
}

variable "chat_id" {
  type = string
}

variable "google_credentials_json" {
  type      = string
  sensitive = true
}
