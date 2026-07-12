output "cloud_run_url" {
  description = "The URL of the deployed Cloud Run service"
  value       = module.cloud_run.cloud_run_url
}

output "registry_repository_url" {
  description = "The Artifact Registry Docker Repository URL"
  value       = module.cloud_run.registry_repository_url
}

output "app_service_account_email" {
  description = "The custom Service Account email assigned to the Cloud Run service"
  value       = module.cloud_run.app_service_account_email
}

output "github_actions_service_account_email" {
  description = "The Service Account email for GitHub Actions deployment"
  value       = module.cloud_run.github_actions_service_account_email
}

output "messaging_trigger_url" {
  description = "The HTTP endpoint URL to trigger the daily/monthly messaging routine"
  value       = module.cloud_run.messaging_trigger_url
}

