# GitHub Actions deploys from the main branch with Workload Identity
# Federation: no service account keys exist. The pool is 燕衛将棋's; this
# repository gets its own provider in it.
data "google_project" "this" {}

locals {
  github_pool = "projects/${data.google_project.this.number}/locations/global/workloadIdentityPools/${var.github_pool_id}"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = var.github_pool_id
  workload_identity_pool_provider_id = "doubt-github-actions"
  display_name                       = "GitHub Actions (doubt)"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }
  attribute_condition = "assertion.repository == '${var.github_repository}' && assertion.ref == 'refs/heads/main'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account" "deployer" {
  account_id   = "doubt-deployer"
  display_name = "ダウト将棋 deploy (GitHub Actions)"
}

resource "google_service_account_iam_member" "deployer_wif" {
  service_account_id = google_service_account.deployer.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${local.github_pool}/attribute.repository/${var.github_repository}"
}

# Push images
resource "google_artifact_registry_repository_iam_member" "deployer_push" {
  location   = google_artifact_registry_repository.doubt.location
  repository = google_artifact_registry_repository.doubt.name
  role       = "roles/artifactregistry.writer"
  member     = google_service_account.deployer.member
}

# Deploy new revisions of the API (and nothing else on Cloud Run)
resource "google_cloud_run_v2_service_iam_member" "deployer_run" {
  name     = google_cloud_run_v2_service.api.name
  location = var.region
  role     = "roles/run.developer"
  member   = google_service_account.deployer.member
}

# A revision runs as the API's service account
resource "google_service_account_iam_member" "deployer_act_as_api" {
  service_account_id = google_service_account.api.name
  role               = "roles/iam.serviceAccountUser"
  member             = google_service_account.deployer.member
}

# Publish the frontend. Hosting has no per-site role, so this deployer can
# also publish 燕衛将棋's site (and the other way round).
resource "google_project_iam_member" "deployer_hosting" {
  project = var.project_id
  role    = "roles/firebasehosting.admin"
  member  = google_service_account.deployer.member
}

# `gcloud run deploy` and the Firebase CLI read the project
resource "google_project_iam_member" "deployer_viewer" {
  project = var.project_id
  role    = "roles/run.viewer"
  member  = google_service_account.deployer.member
}
