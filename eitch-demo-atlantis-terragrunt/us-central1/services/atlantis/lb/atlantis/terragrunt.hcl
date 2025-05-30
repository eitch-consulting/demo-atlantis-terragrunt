terraform {
  source = "tfr:///terraform-google-modules/lb-http/google//modules/serverless_negs?version=12.0.0"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  project_vars = read_terragrunt_config(find_in_parent_folders("project.hcl")).locals
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals
  service_vars = read_terragrunt_config(find_in_parent_folders("service.hcl")).locals
}

dependencies {
  paths = [
    format("%s/cloud-run/atlantis", dirname(find_in_parent_folders("service.hcl"))),
    format("%s/neg/cloudrun-atlantis", dirname(find_in_parent_folders("service.hcl"))),
    format("%s/_global/services/atlantis/selfmanaged-certificate/atlantis.eitch-consulting.com", dirname(find_in_parent_folders("project.hcl")))
  ]
}

dependency "neg" {
  config_path = format("%s/neg/cloudrun-atlantis", dirname(find_in_parent_folders("service.hcl")))
}

dependency "certificate" {
  config_path = format("%s/_global/services/atlantis/selfmanaged-certificate/atlantis.eitch-consulting.com", dirname(find_in_parent_folders("project.hcl")))
}

inputs = {
  name    = "atlantis"
  project = local.project_vars.project_id

  ssl                    = true
  certificate_map        = dependency.certificate.outputs.map_id
  create_ssl_certificate = false
  https_redirect         = true
  load_balancing_scheme  = "EXTERNAL_MANAGED"

  backends = {
    default = {
      protocol   = "HTTP"
      enable_cdn = false

      connection_draining_timeout_sec = 5

      groups = [
        {
          group = dependency.neg.outputs.cloudrun_id
        }
      ]

      iap_config = {
        enable = false
      }

      log_config = {
        enable = false
      }
    }
  }

  labels = local.service_vars.labels
}
