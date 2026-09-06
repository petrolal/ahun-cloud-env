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

# Authenticated with the single shared Ahun bot token (from @BotFather).
provider "telegram" {
  bot_token = var.telegram_bot_token
}

# One Telegram bot shared by both services. Stores the BotFather token in Secret
# Manager and manages the bot profile (commands / webhook). Each service routes
# its own messages via its TELEGRAM_CHAT_ID.
#
# `commands` is the bot's slash-command menu (setMyCommands), derived from each
# service's capabilities. It only publishes the menu users see when they type
# "/"; the behaviour behind each command must be implemented in the owning
# service's Telegram update handler (today ahun-members-service is send-only and
# ahun-duty-service has no Telegram code yet).
module "telegram_bot" {
  source    = "./modules/telegram_bot"
  bot_name  = "ahun"
  bot_token = var.telegram_bot_token

  commands = [
    # --- ahun-members-service (birthdays + Google Sheet sync) ---
    { command = "aniversariantes", description = "Aniversariantes do mês atual" },
    { command = "aniversariantes_hoje", description = "Aniversariantes de hoje" },
    { command = "membros", description = "Lista todos os membros cadastrados" },
    { command = "sincronizar", description = "Sincroniza a planilha do Google com o banco" },

    # --- ahun-duty-service (escala de plantão) — menu only until the service
    #     implements its Telegram handlers ---
    { command = "escala", description = "Escala de plantão atual" },
    { command = "escala_proxima", description = "Próxima escala de plantão" },
    { command = "escala_cartao", description = "Gera o cartão da escala de plantão" },
  ]

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
    TELEGRAM_BOT_TOKEN = module.telegram_bot.secret_id
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

  # Same shared bot token from Secret Manager, ready for the service to consume
  # once its Telegram integration is implemented.
  secret_env_vars = {
    TELEGRAM_BOT_TOKEN = module.telegram_bot.secret_id
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
