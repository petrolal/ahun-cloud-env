variable "organization_id" {
  type        = string
  description = "Supabase Organization ID"
}

variable "databases" {
  description = "Map of database configurations. The key is a logical name (e.g. 'primary'), and the value contains the project settings."
  type = map(object({
    project_name      = string
    database_password = string
    region            = optional(string, "us-east-1")
  }))
}
