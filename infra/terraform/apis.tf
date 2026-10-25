# 燕衛将棋 enables these in the same project too; listing them here keeps this
# app's apply working on its own
locals {
  services = [
    "artifactregistry.googleapis.com",
    "firebase.googleapis.com",
    "firebasehosting.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "run.googleapis.com",
    "sts.googleapis.com",
  ]
}

resource "google_project_service" "this" {
  for_each = toset(local.services)

  service = each.value
  # Other apps share this project: never switch an API off on destroy
  disable_on_destroy = false
}
