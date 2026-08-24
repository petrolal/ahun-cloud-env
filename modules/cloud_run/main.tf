# Cloud Run Service (Always Free eligible under usage limits)
resource "google_cloud_run_v2_service" "app" {
  name     = var.service_name
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.app_sa.email

    # Scale to 0 to guarantee Always Free eligibility when idle
    scaling {
      min_instance_count = 0
      max_instance_count = 5
    }

    containers {
      # Points to the image path in Artifact Registry
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.repository_id}/${var.service_name}:latest"

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }

      ports {
        container_port = 8080
      }

      # Inject all application environment variables dynamically
      dynamic "env" {
        for_each = var.env_vars
        content {
          name  = env.key
          value = env.value
        }
      }
    }
  }

  # Ensure the service starts after the repository is created
  depends_on = [google_artifact_registry_repository.repo]
}
