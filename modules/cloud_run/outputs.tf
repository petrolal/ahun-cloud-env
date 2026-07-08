output "cloud_run_url" {
  description = "The URL of the deployed Cloud Run service"
  value       = google_cloud_run_v2_service.app.uri
}

output "registry_repository_url" {
  description = "The Artifact Registry Docker Repository URL"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.repository_id}"
}

output "app_service_account_email" {
  description = "The custom Service Account email assigned to the Cloud Run service"
  value       = google_service_account.app_sa.email
}
