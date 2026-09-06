output "secret_id" {
  description = "The Secret Manager secret id holding the bot token (pass to cloud_run secret_env_vars)"
  value       = google_secret_manager_secret.bot_token.secret_id
}

output "secret_name" {
  description = "The fully qualified Secret Manager secret resource name"
  value       = google_secret_manager_secret.bot_token.id
}

output "bot_username" {
  description = "The @username of the bot resolved from getMe"
  value       = data.telegram_bot.this.username
}

output "bot_link" {
  description = "Public t.me link for the bot"
  value       = "https://t.me/${data.telegram_bot.this.username}"
}
