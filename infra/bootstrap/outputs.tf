output "GCP_PROJECT_ID" {
  description = "GCP project ID (matches GitHub Environment var name)"
  value       = var.project_id
}

output "project_number" {
  description = "GCP project number"
  value       = data.google_project.current.number
}

output "GCP_WIF_PROVIDER" {
  description = "Full WIF provider resource name (matches GitHub Environment var name)"
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "GCP_TF_SA_EMAIL" {
  description = "Terraform admin service account email (matches GitHub Environment var name)"
  value       = google_service_account.tf_admin.email
}

output "TF_STATE_BUCKET" {
  description = "Terraform state bucket name (matches GitHub Environment var name)"
  value       = google_storage_bucket.tf_state.name
}

output "GCP_REGION" {
  description = "Default GCP region (matches GitHub Environment var name)"
  value       = var.region
}
