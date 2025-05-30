terraform {
  source = "tfr:///terraform-google-modules/service-accounts/google?version=4.5.4"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  project_vars = read_terragrunt_config(find_in_parent_folders("project.hcl")).locals
  project_id   = local.project_vars.project_id
}

dependencies {
  paths = [
    format("%s/_global/infrastructure/account", dirname(find_in_parent_folders("project.hcl")))
  ]
}

inputs = {
  names      = ["atlantis"]
  project_id = local.project_id

  project_roles = [
    "${local.project_id}=>roles/editor",
    "${local.project_id}=>roles/resourcemanager.projectIamAdmin",
    "${local.project_id}=>roles/secretmanager.secretAccessor",
    "${local.project_id}=>roles/iap.settingsAdmin",
    "${local.project_id}=>roles/iap.admin"
  ]

  generate_keys = true
}
