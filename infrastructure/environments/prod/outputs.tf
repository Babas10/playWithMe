output "project_id" {
  description = "The Firebase project ID"
  value       = module.firebase.project_id
}

output "project_number" {
  description = "The Firebase project number"
  value       = module.firebase.project_number
}

output "firestore_database_name" {
  description = "The Firestore database name"
  value       = module.firebase.firestore_database_name
}

output "service_account_email" {
  description = "The Firebase admin service account email"
  value       = module.firebase.service_account_email
}