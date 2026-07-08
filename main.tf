terraform {
  required_version = ">= 1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Cloud Run Module (Hosts the container and schedules cron jobs via Cloud Scheduler)
module "cloud_run" {
  source                     = "./modules/cloud_run"
  project_id                 = var.project_id
  region                     = var.region
  service_name               = var.service_name
  spring_datasource_url      = var.spring_datasource_url
  spring_datasource_username = var.spring_datasource_username
  spring_datasource_password = var.spring_datasource_password
  telegram_bot_token         = var.telegram_bot_token
  telegram_chat_id           = var.telegram_chat_id
  google_credentials         = var.google_credentials

  # Ensure APIs are fully enabled before trying to create resources inside the module
  depends_on = [
    google_project_service.run_api,
    google_project_service.artifact_registry_api,
    google_project_service.scheduler_api,
    google_project_service.iam_api
  ]
}
