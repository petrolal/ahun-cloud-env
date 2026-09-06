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

variable "env_vars" {
  description = "A map of plaintext environment variables to inject into the container"
  type        = map(string)
  default     = {}
}

variable "secret_env_vars" {
  description = "A map of environment variable name => Secret Manager secret id. Injected as secret references and the app SA is granted secretAccessor on each."
  type        = map(string)
  default     = {}
}

variable "scheduler_jobs" {
  description = "A map of scheduler jobs to invoke the Cloud Run service"
  type = map(object({
    description = string
    schedule    = string
    time_zone   = string
    uri_path    = string
    http_method = string
    body        = string
  }))
  default = {}
}
