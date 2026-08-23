variable "project_id" {
  description = "The GCP Project ID where resources will be created"
  type        = string
}

variable "region" {
  description = "The region for the resources (must be us-central1, us-east1, or us-west1 for free tier)"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The zone inside the region"
  type        = string
  default     = "us-central1-a"
}

variable "service_name" {
  description = "Name of the Cloud Run service"
  type        = string
  default     = "ahun-members-service"
}

# --- Application Configuration Variables ---


variable "spring_datasource_password" {
  description = "Supabase Database Password"
  type        = string
  sensitive   = true
}

variable "telegram_bot_token" {
  description = "Telegram Bot Token"
  type        = string
  sensitive   = true
}

variable "telegram_chat_id" {
  description = "Telegram Chat ID for notifications"
  type        = string
  sensitive   = true
}

variable "google_credentials" {
  description = "Google Service Account JSON string for Sheets API (defaults to DEFAULT_GCP to use Cloud Run Application Default Credentials)"
  type        = string
  sensitive   = true
  default     = "DEFAULT_GCP"
}

variable "supabase_access_token" {
  description = "Supabase Access Token"
  type        = string
  sensitive   = true
}

variable "supabase_organization_id" {
  description = "Supabase Organization ID"
  type        = string
}
