resource "google_compute_region_network_endpoint_group" "cloudrun_neg" {
  count = (var.cloud_run_service != null || var.cloud_run_url_mask != null) ? 1 : 0

  project               = var.project
  name                  = var.name
  network_endpoint_type = var.network_endpoint_type
  region                = var.region

  cloud_run {
    service  = var.cloud_run_service
    url_mask = var.cloud_run_url_mask
  }
}
