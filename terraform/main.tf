provider "google" {
  project = var.project_id
  region  = local.region
  zone    = local.zone
}
