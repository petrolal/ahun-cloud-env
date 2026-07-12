# Artifact Registry to store application container image (prefixed with service_name)
resource "google_artifact_registry_repository" "repo" {
  location      = var.region
  repository_id = "${var.service_name}-repo"
  description   = "Docker repository for ${var.service_name}"
  format        = "DOCKER"

  cleanup_policy_dry_run = false

  # Policy 1: Delete images older than 14 days (14 days * 24h * 3600s = 1209600s)
  cleanup_policies {
    id     = "delete-old-images"
    action = "DELETE"
    condition {
      tag_state  = "ANY"
      older_than = "1209600s"
    }
  }

  # Policy 2: Keep the 2 most recent versions (safeguard)
  cleanup_policies {
    id     = "keep-recent-versions"
    action = "KEEP"
    most_recent_versions {
      keep_count = 2
    }
  }
}
