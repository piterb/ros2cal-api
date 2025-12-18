output "ARTIFACT_REPO" {
  description = "Artifact Registry repository name (matches GitHub Environment var name)"
  value       = google_artifact_registry_repository.docker.repository_id
}

output "CLOUD_RUN_SERVICE" {
  description = "Cloud Run service name (matches GitHub Environment var name)"
  value       = google_cloud_run_v2_service.app.name
}

output "cloud_run_service_url" {
  description = "Cloud Run service URL"
  value       = google_cloud_run_v2_service.app.uri
}

output "GCP_DEPLOY_SA_EMAIL" {
  description = "Deploy service account email (matches GitHub Environment var name)"
  value       = google_service_account.runtime.email
}
