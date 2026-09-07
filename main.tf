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
      database_name     = "ahun_members_service"
    }
    "duty" = {
      project_name      = "ahun-duty-db"
      database_password = var.spring_datasource_password
      database_name     = "ahun_duty_service"
    }
  }
}

locals {
  services = {
    "ahun-members-service" = "petrolal/ahun-members-service"
    "ahun-duty-service"    = "petrolal/ahun-duty-service"
  }
}

# Artifact Registry (One Docker repo per service)
module "artifact_registry" {
  source       = "./modules/artifact_registry"
  project_id   = var.project_id
  region       = var.region
  repositories = { for k, v in local.services : k => k }

  depends_on = [google_project_service.artifact_registry_api]
}

# GitHub Actions CI/CD identities (Workload Identity Federation). One SA per
# service repo, each impersonable only from its own repo. The service pipelines
# authenticate with these instead of a JSON key.
module "github_actions_oidc" {
  source       = "./modules/github_actions_oidc"
  project_id   = var.project_id
  github_owner = "petrolal"
  services     = local.services

  depends_on = [google_project_service.iam_api]
}

# NOTE: The Cloud Run services themselves are NOT managed here. Each service repo
# owns its own Terraform root under `<repo>/gcp/` (with a vendored copy of the
# cloud_run module at `<repo>/gcp/modules/cloud_run/`), applied by that service's
# GitHub Actions pipeline right before it deploys the container.
# This root only provisions the shared pieces every service consumes:
#   - project API enablement (apis.tf)
#   - Supabase projects (module.supabase)
#   - the Telegram bot secret + profile (module.telegram_bot)
# Feed the per-service pipeline these outputs as TF_VAR_*:
#   spring_datasource_urls["<svc>"]  -> TF_VAR_spring_datasource_url
#   bot_token_secret                 -> TF_VAR_bot_token_secret_id
