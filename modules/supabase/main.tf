terraform {
  required_providers {
    supabase = {
      source  = "supabase/supabase"
      version = "~> 1.0"
    }
  }
}

resource "supabase_project" "db" {
  for_each          = var.databases
  organization_id   = var.organization_id
  name              = each.value.project_name
  database_password = each.value.database_password
  region            = each.value.region

  lifecycle {
    ignore_changes = [database_password]
  }
}
