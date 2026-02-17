terraform {
  required_version = ">= 0.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.32.1"
    }
  }

  backend "s3" {
    bucket = "casa-ahun-assets"
    key    = "state/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

module "s3_bucket" {
  source      = "./modules/s3_bucket"
  bucket_name = var.bucket_name
}

module "lambda_scheduler" {
  source = "./modules/lambda_scheduler"

  s3_bucket               = module.s3_bucket.bucket_name
  google_credentials_json = var.google_credentials_json

  # Telegram Bot data
  telegram_token = var.telegram_token
  chat_id        = var.chat_id

  # Google Sheets data
  worksheet_name = var.worksheet_name
  name_column    = var.name_column
  date_column    = var.date_column

  # Lambda data for birthdays
  lambda_birthday_name    = var.lambda_birthday_name
  lambda_birthday_zip_key = var.lambda_birthday_zip_key
  spreadsheet_birthday_id = var.spreadsheet_birthday_id
}
