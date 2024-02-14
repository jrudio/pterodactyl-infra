resource "google_storage_bucket" "wing_certificates" {
  name                     = "${var.project.id}-wing-certificates"
  location                 = var.certificate_bucket_location != "" ? var.certificate_bucket_location : "US"
  force_destroy            = false
  public_access_prevention = "enforced"
  versioning {
    enabled = true
  }
}