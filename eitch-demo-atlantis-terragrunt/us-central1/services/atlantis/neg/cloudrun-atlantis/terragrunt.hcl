terraform {
  source = "${get_path_to_repo_root()}//modules/google-cloud-regional-neg"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  project_vars = read_terragrunt_config(find_in_parent_folders("project.hcl")).locals
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals
}

dependencies {
  paths = [
    format("%s/cloud-run/atlantis", dirname(find_in_parent_folders("service.hcl")))
  ]
}

dependency "cloudrun" {
  config_path = format("%s/cloud-run/atlantis", dirname(find_in_parent_folders("service.hcl")))
}

inputs = {
  project           = local.project_vars.project_id
  name              = "cloudrun-atlantis"
  region            = local.region_vars.region
  cloud_run_service = dependency.cloudrun.outputs.service_name
}
