resource "google_artifact_registry_repository" "repo" {
  for_each      = var.repositories
  project       = var.project_id
  location      = var.region
  repository_id = each.key
  description   = "Docker repository for ${each.key}"
  format        = "DOCKER"

  cleanup_policy_dry_run = false

  # Policy 1: Delete images older than 14 days
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
