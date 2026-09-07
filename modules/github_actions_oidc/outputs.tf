output "provider_name" {
  description = "Full resource name of the Workload Identity Pool Provider. Set as the GitHub secret WIF_PROVIDER in every service repo."
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "service_account_emails" {
  description = "Map of service name => CI service account email. In each service repo set the matching value as the GitHub secret WIF_SERVICE_ACCOUNT (and pass it to that root's Terraform as TF_VAR_github_actions_sa_email)."
  value       = { for k, sa in google_service_account.ci : k => sa.email }
}
