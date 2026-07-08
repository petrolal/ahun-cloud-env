variable "service_name" {
  description = "Name of the Cloud Run service"
  type        = string
  default     = "ahun-members-service"
}

variable "region" {
  description = "The region for resources"
  type        = string
}

variable "project_id" {
  description = "The GCP Project ID"
  type        = string
}

# --- Application Configuration Variables ---

variable "spring_datasource_url" {
  description = "Supabase PostgreSQL Database JDBC Connection URL"
  type        = string
  sensitive   = true
}

variable "spring_datasource_username" {
  description = "Supabase Database Username"
  type        = string
  sensitive   = true
}

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
