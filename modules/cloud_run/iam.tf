# Dedicated Service Account for the Application Container
resource "google_service_account" "app_sa" {
  account_id   = "${var.service_name}-app-sa"
  display_name = "Service Account for ${var.service_name} App"
}

# Dedicated Service Account for Cloud Scheduler to invoke Cloud Run securely
resource "google_service_account" "scheduler_sa" {
  account_id   = "${var.service_name}-sched-sa" # Keep it under 30 chars
  display_name = "Cloud Scheduler Invoker Account for ${var.service_name}"
}

# Bind Cloud Run Invoker role to the Scheduler Service Account
resource "google_cloud_run_v2_service_iam_member" "scheduler_invoker" {
  location = google_cloud_run_v2_service.app.location
  project  = google_cloud_run_v2_service.app.project
  name     = google_cloud_run_v2_service.app.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.scheduler_sa.email}"
}

# Service Account for GitHub Actions CI/CD deployment
resource "google_service_account" "github_actions_sa" {
  account_id   = "${var.service_name}-github-sa"
  display_name = "GitHub Actions CI/CD Deployment SA for ${var.service_name}"
}

# Grant Artifact Registry Writer
resource "google_project_iam_member" "github_sa_registry" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

# Grant Cloud Run Developer
resource "google_project_iam_member" "github_sa_run" {
  project = var.project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

# Allow GitHub SA to act as the runtime service account
resource "google_service_account_iam_member" "github_sa_act_as_app" {
  service_account_id = google_service_account.app_sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

# Allow unauthenticated (public) access to the service
resource "google_cloud_run_v2_service_iam_member" "public_invoker" {
  location = google_cloud_run_v2_service.app.location
  project  = google_cloud_run_v2_service.app.project
  name     = google_cloud_run_v2_service.app.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

