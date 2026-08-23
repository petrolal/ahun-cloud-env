variable "organization_id" {
  type        = string
  description = "Supabase Organization ID"
}

variable "project_name" {
  type        = string
  description = "Supabase Project Name"
  default     = "ahun-members-db"
}

variable "database_password" {
  type        = string
  description = "Supabase Database Password"
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Region for the Supabase project"
  default     = "us-east-1"
}
