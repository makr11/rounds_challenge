terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
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
  name          = "rounds-challenge-files"
  location      = "US"
  force_destroy = true

  uniform_bucket_level_access = true
}

resource "google_compute_backend_bucket" "files_backend" {
  name        = "rounds-challenge-files-backend"
  bucket_name = google_storage_bucket.files_bucket.name
  enable_cdn  = true
}

resource "random_id" "url_signature" {
  byte_length = 16
}

resource "google_compute_backend_bucket_signed_url_key" "backend_key" {
  name           = "test-key"
  key_value      = random_id.url_signature.b64_url
  backend_bucket = google_compute_backend_bucket.files_backend.name
}

resource "google_compute_url_map" "files_urlmap" {
  name            = "rounds-challenge-files-url-map"
  default_service = google_compute_backend_bucket.files_backend.self_link
}
