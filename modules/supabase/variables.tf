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
    # Database to target in the JDBC URL. Supabase always provisions a database
    # named "postgres"; any other name must be created manually with
    # `CREATE DATABASE <name>` and is reachable only on the direct 5432
    # connection (the pooler, REST API and backups only serve "postgres").
    database_name = optional(string, "postgres")
  }))
}
