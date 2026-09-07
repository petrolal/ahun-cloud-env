variable "project_id" {
  description = "GCP project that hosts the CI service accounts and their IAM bindings"
  type        = string
}

variable "github_owner" {
  description = "GitHub user or org that owns the service repos. The OIDC provider rejects tokens from any repo outside this owner."
  type        = string
}

variable "services" {
  description = <<-EOT
    Map of service name => "owner/repo" slug. One CI/CD service account is created
    per entry and can be impersonated only by workflows running in that repo.
  EOT
  type        = map(string)
}

variable "pool_id" {
  description = "Workload Identity Pool id"
  type        = string
  default     = "github-actions"
}

variable "provider_id" {
  description = "Workload Identity Pool Provider id"
  type        = string
  default     = "github"
}
