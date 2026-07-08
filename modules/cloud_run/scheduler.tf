# Cloud Scheduler: Daily Birthday Check (Always Free eligible - up to 3 jobs free)
resource "google_cloud_scheduler_job" "daily_birthday_job" {
  name             = "${var.service_name}-daily-bday"
  description      = "Sends daily birthday notifications via Telegram"
  schedule         = "0 8 * * *" # Every day at 08:00
  time_zone        = "America/Sao_Paulo"
  attempt_deadline = "320s"

  http_target {
    http_method = "POST"
    uri         = "${google_cloud_run_v2_service.app.uri}/api/messaging/send"
    body        = base64encode("{\"daily\":true}")
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

# Cloud Scheduler: Monthly Notification (Always Free eligible - up to 3 jobs free)
resource "google_cloud_scheduler_job" "monthly_notification_job" {
  name             = "${var.service_name}-monthly-notif"
  description      = "Sends monthly members notifications via Telegram"
  schedule         = "0 9 1 * *" # First day of each month at 09:00
  time_zone        = "America/Sao_Paulo"
  attempt_deadline = "320s"

  http_target {
    http_method = "POST"
    uri         = "${google_cloud_run_v2_service.app.uri}/api/messaging/send"
    body        = base64encode("{\"daily\":false}")
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
