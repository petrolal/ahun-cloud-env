output "members_cloud_run_url" {
  description = "The URL of the deployed Ahun Members Cloud Run service"
  value       = module.ahun_members_service.cloud_run_url
}

output "members_registry_repository_url" {
  description = "The Artifact Registry Docker Repository URL for Ahun Members"
  value       = module.ahun_members_service.registry_repository_url
}

output "members_app_service_account_email" {
  description = "The custom Service Account email assigned to the Ahun Members Cloud Run service"
  value       = module.ahun_members_service.app_service_account_email
}

output "members_github_actions_service_account_email" {
  description = "The Service Account email for GitHub Actions deployment for Ahun Members"
  value       = module.ahun_members_service.github_actions_service_account_email
}

output "members_messaging_trigger_url" {
  description = "The HTTP endpoint URL to trigger the daily/monthly messaging routine for Ahun Members"
  value       = module.ahun_members_service.messaging_trigger_url
}

output "duty_cloud_run_url" {
  description = "The URL of the deployed Ahun Duty Cloud Run service"
  value       = module.ahun_duty_service.cloud_run_url
}

output "duty_registry_repository_url" {
  description = "The Artifact Registry Docker Repository URL for Ahun Duty"
  value       = module.ahun_duty_service.registry_repository_url
}

output "duty_app_service_account_email" {
  description = "The custom Service Account email assigned to the Ahun Duty Cloud Run service"
  value       = module.ahun_duty_service.app_service_account_email
}

output "duty_github_actions_service_account_email" {
  description = "The Service Account email for GitHub Actions deployment for Ahun Duty"
  value       = module.ahun_duty_service.github_actions_service_account_email
}

output "duty_messaging_trigger_url" {
  description = "The HTTP endpoint URL to trigger the daily/monthly messaging routine for Ahun Duty"
  value       = module.ahun_duty_service.messaging_trigger_url
}

# --- Telegram bot (shared by both services) ---

output "bot_username" {
  description = "Resolved @username of the shared Ahun Telegram bot"
  value       = module.telegram_bot.bot_username
}

output "bot_link" {
  description = "Public t.me link for the shared Ahun Telegram bot"
  value       = module.telegram_bot.bot_link
}

output "bot_token_secret" {
  description = "Secret Manager secret id holding the shared Ahun bot token"
  value       = module.telegram_bot.secret_id
}
