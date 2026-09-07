output "repositories" {
  description = "Map of created Artifact Registry repositories"
  value       = { for k, r in google_artifact_registry_repository.repo : k => r.name }
}
