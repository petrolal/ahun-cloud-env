# Workload Identity Federation for GitHub Actions.
#
# Replaces long-lived service-account JSON keys: each service's pipeline mints a
# short-lived GitHub OIDC token and exchanges it for GCP credentials. Nothing to
# rotate, and a deleted/rotated key can no longer break a deploy.
#
# One pool + one provider for every repo owned by var.github_owner; one service
# account per service, impersonable only from that service's own repo.

resource "google_iam_workload_identity_pool" "github" {
  project                   = var.project_id
  workload_identity_pool_id = var.pool_id
  display_name              = "GitHub Actions"
  description               = "OIDC federation for GitHub Actions workflows"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = var.provider_id
  display_name                       = "GitHub OIDC"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
  }

  # Google requires an attribute condition for the github.com issuer. Restrict to
  # repos under this owner so a token from any other GitHub repo is rejected
  # before it ever reaches a per-repo binding below.
  attribute_condition = "assertion.repository_owner == \"${var.github_owner}\""

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# One CI/CD identity per service.
resource "google_service_account" "ci" {
  for_each     = var.services
  project      = var.project_id
  account_id   = "${each.key}-github-sa"
  display_name = "GitHub Actions CI/CD for ${each.key}"
}

# Only workflows from that service's own repo may impersonate its SA.
resource "google_service_account_iam_member" "wif" {
  for_each           = var.services
  service_account_id = google_service_account.ci[each.key].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${each.value}"
}

locals {
  ci_roles = [
    "roles/artifactregistry.writer",
    "roles/run.admin",
    "roles/cloudscheduler.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountUser",
    "roles/secretmanager.admin",
    "roles/storage.objectUser",
  ]

  service_roles = merge([
    for svc_name, repo in var.services : {
      for role in local.ci_roles : "${svc_name}_${role}" => {
        service_account_email = google_service_account.ci[svc_name].email
        role                  = role
      }
    }
  ]...)
}

# Permissions granted to each service's CI/CD service account so its pipeline
# can push images, provision its per-service Cloud Run infra, and deploy revisions.
resource "google_project_iam_member" "ci_roles" {
  for_each = local.service_roles
  project  = var.project_id
  role     = each.value.role
  member   = "serviceAccount:${each.value.service_account_email}"
}

