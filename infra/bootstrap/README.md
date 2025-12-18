# Bootstrap Terraform (local only)

Purpose: create the trust root for GitHub OIDC, the Terraform admin service account, and the GCS state bucket.

## Prereqs
- Installed: Terraform, gcloud CLI
- Auth (local human account):
  - `gcloud auth login`
  - `gcloud auth application-default login`

## Run
```bash
cd infra/bootstrap
terraform init
terraform apply \
  -var "project_id=REPLACE_WITH_PROJECT_ID" \
  -var "region=REPLACE_WITH_REGION" \
  -var "github_repo=ORG/REPO"
```
Optional: override the state bucket name with `-var "tf_state_bucket_name=YOUR_BUCKET_NAME"` (default is `<project_id>-tf-state`).

## Outputs to copy into GitHub Environment (prod)
The bootstrap outputs are named to match the GitHub Environment variables:
- `GCP_PROJECT_ID`
- `GCP_REGION`
- `GCP_WIF_PROVIDER`
- `GCP_TF_SA_EMAIL`
- `TF_STATE_BUCKET`

## Notes
- The principal set binding is restricted to `ORG/REPO` via attribute condition.
- This bootstrap should be run locally under an elevated human account only.
