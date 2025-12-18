data "google_project" "current" {
  project_id = var.project_id
}

locals {
  principal_set = "principalSet://iam.googleapis.com/projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/${var.wif_pool_id}/attribute.repository/${var.github_repo}"
  tf_roles = [
    "roles/serviceusage.serviceUsageAdmin",
    "roles/run.admin",
    "roles/artifactregistry.admin",
    "roles/secretmanager.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/resourcemanager.projectIamAdmin",
  ]
  tf_state_bucket_name = coalesce(var.tf_state_bucket_name, "${var.project_id}-tf-state")
}

resource "google_iam_workload_identity_pool" "github" {
  project                   = var.project_id
  workload_identity_pool_id = var.wif_pool_id
  display_name              = "GitHub OIDC Pool"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = var.wif_provider_id
  display_name                       = "GitHub OIDC Provider"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
  }

  attribute_condition = "assertion.repository == \"${var.github_repo}\""
}

resource "google_service_account" "tf_admin" {
  project      = var.project_id
  account_id   = var.tf_service_account_id
  display_name = "Terraform Admin"
}

resource "google_service_account_iam_member" "wif_impersonation" {
  service_account_id = google_service_account.tf_admin.name
  role               = "roles/iam.workloadIdentityUser"
  member             = local.principal_set
}

resource "google_service_account_iam_member" "wif_token_creator" {
  service_account_id = google_service_account.tf_admin.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = local.principal_set
}

resource "google_project_iam_member" "tf_admin_roles" {
  for_each = toset(local.tf_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.tf_admin.email}"
}

resource "google_storage_bucket" "tf_state" {
  name                        = local.tf_state_bucket_name
  project                     = var.project_id
  location                    = var.region
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}

resource "google_storage_bucket_iam_member" "tf_state_admin" {
  bucket = google_storage_bucket.tf_state.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.tf_admin.email}"
}
