terraform {
  source = "tfr:///GoogleCloudPlatform/artifact-registry/google?version=0.2.0"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  project_vars = read_terragrunt_config(find_in_parent_folders("project.hcl")).locals
  service_vars = read_terragrunt_config(find_in_parent_folders("service.hcl")).locals
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals

  project_id = local.project_vars.project_id
}

dependencies {
  paths = [
    format("%s/_global/infrastructure/account", dirname(find_in_parent_folders("project.hcl"))),
    format("%s/_global/services/atlantis/sa/atlantis", dirname(find_in_parent_folders("project.hcl")))
  ]
}

dependency "sa" {
  config_path = format("%s/_global/services/atlantis/sa/atlantis", dirname(find_in_parent_folders("project.hcl")))
}

inputs = {
  repository_id = "demo"
  project_id    = local.project_vars.project_id
  location      = local.region_vars.location
  format        = "docker"

  members = {
    readers = [
      dependency.sa.outputs.iam_email
    ]
  }

  labels = local.service_vars.labels
}
