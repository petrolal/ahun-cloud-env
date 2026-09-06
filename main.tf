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
    # Telegram bots themselves are created in @BotFather (no API for that).
    # This provider manages an existing bot's webhook/commands and validates the token.
    telegram = {
      source  = "yi-jiayu/telegram"
      version = "~> 0.3"
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

# One aliased Telegram provider per bot - the provider is authenticated with a
# single bot token, so multiple bots need multiple aliased configurations.
provider "telegram" {
  alias     = "members"
  bot_token = var.telegram_bot_token
}

provider "telegram" {
  alias     = "duty"
  bot_token = var.duty_telegram_bot_token
}

# Telegram bot: ahun-members-service
# Stores the BotFather token in Secret Manager and manages the bot profile.
module "telegram_members" {
  source    = "./modules/telegram_bot"
  bot_name  = "ahun-members-service"
  bot_token = var.telegram_bot_token

  providers = {
    telegram = telegram.members
  }

  depends_on = [google_project_service.secretmanager_api]
}

# Telegram bot: ahun-duty-service
module "telegram_duty" {
  source    = "./modules/telegram_bot"
  bot_name  = "ahun-duty-service"
  bot_token = var.duty_telegram_bot_token

  providers = {
    telegram = telegram.duty
  }

  depends_on = [google_project_service.secretmanager_api]
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
    TELEGRAM_CHAT_ID           = var.telegram_chat_id
    GOOGLE_CREDENTIALS         = replace(var.google_credentials, "\n", "")
  }

  # Bot token is injected from Secret Manager rather than as plaintext.
  secret_env_vars = {
    TELEGRAM_BOT_TOKEN = module.telegram_members.secret_id
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
    google_project_service.iam_api,
    google_project_service.secretmanager_api
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
  }

  # Duty bot token from Secret Manager, ready for the service to consume once
  # its Telegram integration is implemented.
  secret_env_vars = {
    TELEGRAM_BOT_TOKEN = module.telegram_duty.secret_id
  }

  scheduler_jobs = {}

  depends_on = [
    google_project_service.run_api,
    google_project_service.artifact_registry_api,
    google_project_service.scheduler_api,
    google_project_service.iam_api,
    google_project_service.secretmanager_api
  ]
}
