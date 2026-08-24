terraform {
  required_version = ">= 1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    supabase = {
      source  = "supabase/supabase"
      version = "~> 1.0"
    }
  }

  backend "gcs" {
    bucket = "casa-ahun-tfstate"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Supabase Module (Provisions Databases)
module "supabase" {
  source          = "./modules/supabase"
  organization_id = var.supabase_organization_id
  databases = {
    "members" = {
      project_name      = "ahun-members-db"
      database_password = var.spring_datasource_password
    }
    "duty" = {
      project_name      = "ahun-duty-db"
      database_password = var.spring_datasource_password
    }
  }
}

# Cloud Run Module: Ahun Members Service (Telegram Bot)
module "ahun_members_service" {
  source       = "./modules/cloud_run"
  project_id   = var.project_id
  region       = var.region
  service_name = "ahun-members-service"

  env_vars = {
    SPRING_DATASOURCE_URL      = module.supabase.spring_datasource_urls["members"]
    SPRING_DATASOURCE_USERNAME = "postgres"
    SPRING_DATASOURCE_PASSWORD = var.spring_datasource_password
    TELEGRAM_BOT_TOKEN         = var.telegram_bot_token
    TELEGRAM_CHAT_ID           = var.telegram_chat_id
    GOOGLE_CREDENTIALS         = replace(var.google_credentials, "\n", "")
  }

  scheduler_jobs = {
    "daily-bday" = {
      description = "Sends daily birthday notifications via Telegram"
      schedule    = "0 8 * * *"
      time_zone   = "America/Sao_Paulo"
      uri_path    = "/api/messaging/send"
      http_method = "POST"
      body        = "{\"daily\":true}"
    }
    "monthly-notif" = {
      description = "Sends monthly members notifications via Telegram"
      schedule    = "0 9 1 * *"
      time_zone   = "America/Sao_Paulo"
      uri_path    = "/api/messaging/send"
      http_method = "POST"
      body        = "{\"daily\":false}"
    }
  }

  depends_on = [
    google_project_service.run_api,
    google_project_service.artifact_registry_api,
    google_project_service.scheduler_api,
    google_project_service.iam_api
  ]
}

# Cloud Run Module: Ahun Duty Service (Telegram Bot)
module "ahun_duty_service" {
  source       = "./modules/cloud_run"
  project_id   = var.project_id
  region       = var.region
  service_name = "ahun-duty-service"

  env_vars = {
    SPRING_DATASOURCE_URL      = module.supabase.spring_datasource_urls["duty"]
    SPRING_DATASOURCE_USERNAME = "postgres"
    SPRING_DATASOURCE_PASSWORD = var.spring_datasource_password
    GOOGLE_CREDENTIALS         = replace(var.google_credentials, "\n", "")
    # Add the Duty bot token here once generated from BotFather:
    # TELEGRAM_BOT_TOKEN         = var.duty_telegram_bot_token
  }
  
  scheduler_jobs = {}

  depends_on = [
    google_project_service.run_api,
    google_project_service.artifact_registry_api,
    google_project_service.scheduler_api,
    google_project_service.iam_api
  ]
}
