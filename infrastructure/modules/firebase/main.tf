terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }
}

# Create or manage the Firebase project
resource "google_project" "firebase_project" {
  name       = var.project_display_name
  project_id = var.project_id

  # Use existing project if it already exists
  lifecycle {
    prevent_destroy = true
  }
}

# Enable required APIs
resource "google_project_service" "firebase_api" {
  project = google_project.firebase_project.project_id
  service = "firebase.googleapis.com"
}

resource "google_project_service" "firestore_api" {
  project = google_project.firebase_project.project_id
  service = "firestore.googleapis.com"
}

resource "google_project_service" "identity_toolkit_api" {
  project = google_project.firebase_project.project_id
  service = "identitytoolkit.googleapis.com"
}

# Initialize Firebase project
resource "google_firebase_project" "default" {
  provider = google-beta
  project  = google_project.firebase_project.project_id

  depends_on = [google_project_service.firebase_api]
}

# Create Firestore database
resource "google_firestore_database" "database" {
  project     = google_project.firebase_project.project_id
  name        = "(default)"
  location_id = var.firestore_location
  type        = "FIRESTORE_NATIVE"

  depends_on = [google_project_service.firestore_api]
}

# Create service account for the project
resource "google_service_account" "firebase_admin" {
  project      = google_project.firebase_project.project_id
  account_id   = "${var.environment}-firebase-admin"
  display_name = "Firebase Admin Service Account for ${var.environment}"
}

# Grant necessary roles to the service account
resource "google_project_iam_member" "firebase_admin_roles" {
  for_each = toset([
    "roles/firebase.admin",
    "roles/datastore.owner",
    "roles/firebase.managementServiceAgent"
  ])

  project = google_project.firebase_project.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.firebase_admin.email}"
}

# Create a key for the service account
resource "google_service_account_key" "firebase_admin_key" {
  service_account_id = google_service_account.firebase_admin.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}