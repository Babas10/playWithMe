terraform {
  required_version = ">= 1.0"

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

  backend "local" {
    path = "terraform-stg.tfstate"
  }
}

provider "google" {
  region = var.region
}

provider "google-beta" {
  region = var.region
}

# Use the shared Firebase module
module "firebase" {
  source = "../../modules/firebase"

  project_id           = var.project_id
  project_display_name = var.project_display_name
  environment         = var.environment
  firestore_location  = var.firestore_location
}