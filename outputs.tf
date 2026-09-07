# --- Supabase (consumed by each service pipeline as TF_VAR_spring_datasource_url) ---

output "spring_datasource_urls" {
  description = "Per-service JDBC URLs. Feed the matching one to that service's pipeline as TF_VAR_spring_datasource_url."
  value       = module.supabase.spring_datasource_urls
}

output "supabase_project_ids" {
  description = "Per-service Supabase project ids"
  value       = module.supabase.project_ids
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
  description = "Secret Manager secret id holding the shared Ahun bot token. Feed to each service pipeline as TF_VAR_bot_token_secret_id."
  value       = module.telegram_bot.secret_id
}

# --- GitHub Actions OIDC (Workload Identity Federation) ---

output "github_actions_wif_provider" {
  description = "Workload Identity Pool Provider resource name. Set as the GitHub secret WIF_PROVIDER in every service repo."
  value       = module.github_actions_oidc.provider_name
}

output "github_actions_sa_emails" {
  description = "Per-service CI service account emails. In each service repo set the matching value as WIF_SERVICE_ACCOUNT and pass it to that root as TF_VAR_github_actions_sa_email."
  value       = module.github_actions_oidc.service_account_emails
}
