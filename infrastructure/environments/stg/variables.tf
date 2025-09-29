variable "project_id" {
  description = "The Firebase project ID for staging environment"
  type        = string
  default     = "playwithme-stg"
}

variable "project_display_name" {
  description = "The display name for the Firebase project"
  type        = string
  default     = "PlayWithMe - Staging"
}

variable "environment" {
  description = "The environment name"
  type        = string
  default     = "stg"
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