resource "google_certificate_manager_certificate" "default" {
  project     = var.project
  name        = var.name
  description = var.description
  scope       = var.scope

  self_managed {
    pem_certificate = var.pem_certificate
    pem_private_key = var.pem_private_key
  }
}

resource "google_certificate_manager_certificate_map" "default" {
  name        = "${var.name}-map"
  description = "Certificate map for ${var.name} certificate"
}

resource "google_certificate_manager_certificate_map_entry" "default" {
  name         = "${var.name}-map-entry"
  description  = "Default entry for ${var.name}-map"
  map          = google_certificate_manager_certificate_map.default.name
  certificates = [google_certificate_manager_certificate.default.id]
  matcher      = "PRIMARY"
}
