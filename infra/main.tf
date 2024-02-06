terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "5.14.0"
    }
  }
  backend "gcs" {
    bucket = "rounds-challenge-terraform-state"
    prefix = "terraform/state"
  }
}

provider "google" {
  credentials = file("rounds-challenge-cf9ad9322383.json")

  project = "rounds-challenge"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_storage_bucket" "files_bucket" {
  name          = "files-storage-123"
  location      = "US"
  force_destroy = true

  uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_binding" "public_read" {
  bucket = google_storage_bucket.files_bucket.name
  role   = "roles/storage.objectViewer"

  members = [
    "allUsers",
  ]
}

resource "google_compute_backend_bucket" "files_backend" {
  name        = "files-backend"
  bucket_name = google_storage_bucket.files_bucket.name
  enable_cdn  = true
}

resource "google_compute_target_http_proxy" "proxy" {
  name    = "http-proxy"
  url_map = google_compute_url_map.files_urlmap.self_link
}

resource "google_compute_global_forwarding_rule" "rule" {
  name       = "http-rule"
  target     = google_compute_target_http_proxy.proxy.self_link
  port_range = "80"
  ip_address = google_compute_global_address.address.address
}

resource "google_compute_global_address" "address" {
  name = "global-address"
}

resource "google_compute_url_map" "files_urlmap" {
  name            = "files-lb"
  default_service = google_compute_backend_bucket.files_backend.self_link
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"

    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth2" {
  location    = "us-central1"
  project     = "rounds-challenge"
  service     = "uat"
  policy_data = data.google_iam_policy.noauth.policy_data
}

resource "google_clouddeploy_target" "files_uat" {
  location = "us-central1"
  name     = "uat"

  project = "rounds-challenge"

  run {
    location = "projects/rounds-challenge/locations/us-central1"
  }
  provider = google-beta
}

resource "google_clouddeploy_target" "files_prod" {
  location         = "us-central1"
  name             = "prod"
  require_approval = true

  project = "rounds-challenge"

  run {
    location = "projects/rounds-challenge/locations/us-central1"
  }
  provider = google-beta
}

resource "google_clouddeploy_delivery_pipeline" "files-deploy" {
  name     = "files-app-prod"
  project  = "rounds-challenge"
  location = "us-central1"

  serial_pipeline {
    stages {
      target_id = "uat"
      profiles  = ["run_uat"]
    }

    stages {
      target_id = "prod"
      profiles  = ["run_prod"]
      strategy {
        canary {
          canary_deployment {
            percentages = [10, 20, 30, 40]
          }
          runtime_config {
            cloud_run {
              automatic_traffic_control = true
            }
          }
        }
      }
    }
  }
  provider = google-beta
}
