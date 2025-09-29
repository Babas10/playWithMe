variable "project_id" {
  description = "The Firebase project ID for production environment"
  type        = string
  default     = "playwithme-prod"
}

variable "project_display_name" {
  description = "The display name for the Firebase project"
  type        = string
  default     = "PlayWithMe - Production"
}

variable "environment" {
  description = "The environment name"
  type        = string
  default     = "prod"
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "europe-west1"
}

variable "firestore_location" {
  description = "The location for Firestore database"
  type        = string
  default     = "eur3"
}