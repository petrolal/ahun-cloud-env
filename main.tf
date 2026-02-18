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

module "lambda_scheduler" {
  source = "./modules/lambda_birthday_scheduler"

  lambda_name = var.lambda_birthday_name
  s3_bucket   = var.s3_bucket
  s3_key      = var.lambda_birthday_zip_key

  spreadsheet_id          = var.spreadsheet_birthday_id
  worksheet_name          = var.worksheet_name
  name_column             = var.name_column
  date_column             = var.date_column
  telegram_token          = var.telegram_token
  chat_id                 = var.chat_id
  google_credentials_json = var.google_credentials_json
}
