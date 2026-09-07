output "project_ids" {
  description = "Map of Supabase project IDs"
  value       = { for k, db in supabase_project.db : k => db.id }
}

output "db_hosts" {
  description = "Map of database host URLs"
  value       = { for k, db in supabase_project.db : k => "db.${db.id}.supabase.co" }
}

output "spring_datasource_urls" {
  description = "Map of JDBC connection strings for Spring Boot (direct 5432 connection, database per the databases[*].database_name input)"
  value       = { for k, db in supabase_project.db : k => "jdbc:postgresql://db.${db.id}.supabase.co:5432/${var.databases[k].database_name}" }
}
