terraform {
  source = "tfr:///terraform-google-modules/cloud-storage/google//modules/simple_bucket?version=10.0.2"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  project_vars = read_terragrunt_config(find_in_parent_folders("project.hcl")).locals
  service_vars = read_terragrunt_config(find_in_parent_folders("service.hcl")).locals
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals
}

inputs = {
  name       = "${local.project_vars.project_id}-testing-iac"
  project_id = local.project_vars.project_id
  location   = local.region_vars.region

  storage_class = "REGIONAL"
  versioning    = false
  force_destroy = true

  soft_delete_policy = {
    retention_duration_seconds = 604800
  }

  labels = local.service_vars.labels
}
