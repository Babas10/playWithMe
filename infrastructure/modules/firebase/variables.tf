variable "project_id" {
  description = "The Firebase project ID"
  type        = string
}

variable "project_display_name" {
  description = "The display name for the Firebase project"
  type        = string
}

variable "environment" {
  description = "The environment name (dev, stg, prod)"
  type        = string
}

variable "firestore_location" {
  description = "The location for Firestore database"
  type        = string
  default     = "europe-west1"
}