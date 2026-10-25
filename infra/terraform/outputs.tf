output "api_url" {
  value = google_cloud_run_v2_service.api.uri
}

output "hosting_url" {
  value = "https://${google_firebase_hosting_site.doubt.site_id}.web.app"
}

output "image_repository" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.doubt.repository_id}"
}

# GitHub Actions variables (see docs/deploy.md)
output "workload_identity_provider" {
  value = google_iam_workload_identity_pool_provider.github.name
}

output "deployer_service_account" {
  value = google_service_account.deployer.email
}

# Records to add at Cloudflare (DNS only, proxy off)
output "dns_records" {
  value = google_firebase_hosting_custom_domain.doubt.required_dns_updates
}
