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
