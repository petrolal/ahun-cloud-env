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

# --- Application Configuration Variables ---

variable "spring_datasource_password" {
  description = "Supabase Database Password"
  type        = string
  sensitive   = true
}

variable "telegram_bot_token" {
  description = "Telegram Bot Token for the shared Ahun bot (issued by @BotFather), used by both services"
  type        = string
  sensitive   = true
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
