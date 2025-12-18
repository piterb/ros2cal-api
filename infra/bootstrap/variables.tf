variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Default GCP region"
  type        = string
  default     = "REPLACE_WITH_REGION"
}

variable "github_repo" {
  description = "GitHub repo in ORG/REPO format"
  type        = string
}

variable "wif_pool_id" {
  description = "Workload Identity Pool ID"
  type        = string
  default     = "github-pool"
}

variable "wif_provider_id" {
  description = "Workload Identity Pool Provider ID"
  type        = string
  default     = "github"
}

variable "tf_service_account_id" {
  description = "Terraform admin service account ID"
  type        = string
  default     = "tf-admin"
}

variable "tf_state_bucket_name" {
  description = "Optional GCS bucket name for Terraform state (defaults to <project_id>-tf-state)"
  type        = string
  default     = null
}
