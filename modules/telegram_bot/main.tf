terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    # Telegram has no API to create a bot; the token must come from @BotFather.
    # This provider only manages an existing bot's webhook and commands.
    telegram = {
      source  = "yi-jiayu/telegram"
      version = "~> 0.3"
    }
  }
}

# Store the BotFather token in Secret Manager instead of a plaintext env var.
resource "google_secret_manager_secret" "bot_token" {
  secret_id = "${var.bot_name}-telegram-bot-token"

  labels = {
    managed-by = "terraform"
    component  = "telegram-bot"
    bot        = var.bot_name
  }

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "bot_token" {
  secret      = google_secret_manager_secret.bot_token.id
  secret_data = var.bot_token
}

# Resolves the bot identity via getMe. Also validates that the token is live.
data "telegram_bot" "this" {}

# setMyCommands - only managed when commands are provided.
resource "telegram_bot_commands" "this" {
  count    = length(var.commands) > 0 ? 1 : 0
  commands = var.commands
}

# setWebhook - only managed when a URL is provided. The Ahun bot stays on long
# polling, so leaving webhook_url empty is the expected default.
resource "telegram_bot_webhook" "this" {
  count           = var.webhook_url != "" ? 1 : 0
  url             = var.webhook_url
  allowed_updates = var.webhook_allowed_updates
}
