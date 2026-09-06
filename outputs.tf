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

# --- Telegram bots ---

output "members_bot_username" {
  description = "Resolved @username of the Ahun Members Telegram bot"
  value       = module.telegram_members.bot_username
}

output "members_bot_link" {
  description = "Public t.me link for the Ahun Members Telegram bot"
  value       = module.telegram_members.bot_link
}

output "members_bot_token_secret" {
  description = "Secret Manager secret id holding the Ahun Members bot token"
  value       = module.telegram_members.secret_id
}

output "duty_bot_username" {
  description = "Resolved @username of the Ahun Duty Telegram bot"
  value       = module.telegram_duty.bot_username
}

output "duty_bot_link" {
  description = "Public t.me link for the Ahun Duty Telegram bot"
  value       = module.telegram_duty.bot_link
}

output "duty_bot_token_secret" {
  description = "Secret Manager secret id holding the Ahun Duty bot token"
  value       = module.telegram_duty.secret_id
}
