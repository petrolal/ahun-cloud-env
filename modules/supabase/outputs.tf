output "project_id" {
  description = "The ID of the Supabase project"
  value       = supabase_project.db.id
}

output "db_host" {
  description = "The database host URL"
  value       = "db.${supabase_project.db.id}.supabase.co"
}

output "spring_datasource_url" {
  description = "JDBC connection string for Spring Boot"
  value       = "jdbc:postgresql://db.${supabase_project.db.id}.supabase.co:5432/postgres"
}
