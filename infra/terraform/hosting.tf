# The page: Firebase Hosting serves frontend/dist and rewrites /api/** to the
# Cloud Run service (frontend/firebase.json). The files themselves are
# published by CI (firebase deploy). The Firebase project is 燕衛将棋's.
resource "google_firebase_hosting_site" "doubt" {
  provider = google-beta
  project  = var.project_id
  site_id  = var.hosting_site_id

  depends_on = [google_project_service.this]
}

# DNS lives at Cloudflare: add the records in the `dns_records` output there,
# with the proxy off (grey cloud), or the certificate is never issued.
resource "google_firebase_hosting_custom_domain" "doubt" {
  provider              = google-beta
  project               = var.project_id
  site_id               = google_firebase_hosting_site.doubt.site_id
  custom_domain         = var.domain
  cert_preference       = "GROUPED"
  wait_dns_verification = false
}
