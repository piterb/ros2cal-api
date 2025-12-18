variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "REPLACE_WITH_REGION"
}

variable "artifact_repo_name" {
  description = "Artifact Registry repository name"
  type        = string
  default     = "REPLACE_WITH_ARTIFACT_REPO"
}

variable "cloud_run_service_name" {
  description = "Cloud Run service name"
  type        = string
  default     = "REPLACE_WITH_SERVICE_NAME"
}

variable "runtime_service_account_id" {
  description = "Cloud Run runtime service account ID"
  type        = string
  default     = "cloud-run-runtime"
}

variable "allow_unauthenticated" {
  description = "Allow public access to the Cloud Run service"
  type        = bool
  default     = false
}

variable "cloud_run_min_instances" {
  description = "Minimum Cloud Run instances"
  type        = number
  default     = 0
}

variable "cloud_run_max_instances" {
  description = "Maximum Cloud Run instances"
  type        = number
  default     = 1
}

variable "cloud_run_image" {
  description = "Container image URI for Cloud Run"
  type        = string
  default     = "REPLACE_WITH_IMAGE_URI"
}
