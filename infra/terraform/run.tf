# The API. Terraform owns the settings; the image is deployed by CI
# (gcloud run deploy), so changes to it are ignored here.
resource "google_service_account" "api" {
  account_id   = "doubt-api"
  display_name = "ダウト将棋 API (Cloud Run)"
}

resource "google_cloud_run_v2_service" "api" {
  name     = "doubt-api"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account                  = google_service_account.api.email
    timeout                          = "60s"
    max_instance_request_concurrency = 40

    scaling {
      min_instance_count = 0
      max_instance_count = var.max_instances
    }

    containers {
      # Placeholder until the first deploy from CI
      image = "us-docker.pkg.dev/cloudrun/container/hello"

      ports {
        container_port = 8080
      }
      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
        cpu_idle          = true # billed only while handling requests
        startup_cpu_boost = true
      }
      env {
        name  = "DOUBT_CORS_ORIGINS"
        value = "https://${var.domain}"
      }
      startup_probe {
        http_get {
          path = "/api/health"
        }
        period_seconds    = 2
        failure_threshold = 15
      }
    }
  }

  lifecycle {
    ignore_changes = [
      template[0].containers[0].image,
      client,
      client_version,
    ]
  }

  depends_on = [google_project_service.this]
}

# Firebase Hosting's rewrite calls the service without credentials
resource "google_cloud_run_v2_service_iam_member" "public" {
  name     = google_cloud_run_v2_service.api.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}
