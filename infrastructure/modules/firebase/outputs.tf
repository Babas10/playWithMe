output "project_id" {
  description = "The Firebase project ID"
  value       = google_project.firebase_project.project_id
}

output "project_number" {
  description = "The Firebase project number"
  value       = google_project.firebase_project.number
}

output "firestore_database_name" {
  description = "The Firestore database name"
  value       = google_firestore_database.database.name
}

output "service_account_email" {
  description = "The Firebase admin service account email"
  value       = google_service_account.firebase_admin.email
}

output "service_account_key" {
  description = "The Firebase admin service account key (base64 encoded)"
  value       = google_service_account_key.firebase_admin_key.private_key
  sensitive   = true
}