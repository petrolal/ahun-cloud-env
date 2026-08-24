resource "google_cloud_scheduler_job" "job" {
  for_each         = var.scheduler_jobs
  name             = "${var.service_name}-${each.key}"
  description      = each.value.description
  schedule         = each.value.schedule
  time_zone        = each.value.time_zone
  attempt_deadline = "320s"

  http_target {
    http_method = each.value.http_method
    uri         = "${google_cloud_run_v2_service.app.uri}${each.value.uri_path}"
    body        = each.value.body != "" ? base64encode(each.value.body) : null
    headers = {
      "Content-Type" = "application/json"
    }

    # Authenticate with Cloud Run using secure OIDC Token
    oidc_token {
      service_account_email = google_service_account.scheduler_sa.email
      audience              = google_cloud_run_v2_service.app.uri
    }
  }
}
