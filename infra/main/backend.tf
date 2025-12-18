terraform {
  backend "gcs" {
    bucket = "rosterapp-481614-tf-state"
    prefix = "terraform/main"
  }
}
