terraform {
  source = "${get_path_to_repo_root()}/modules/google-cloud-selfmanaged-certificate"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  project_vars = read_terragrunt_config(find_in_parent_folders("project.hcl")).locals
  service_vars = read_terragrunt_config(find_in_parent_folders("service.hcl")).locals
}

dependencies {
  paths = [
    format("%s/_global/infrastructure/account", dirname(find_in_parent_folders("project.hcl")))
  ]
}

inputs = {
  project         = local.project_vars.project_id
  name            = "atlantis"
  description     = "atlantis.eitch-consulting.com"
  scope           = "DEFAULT"
  pem_certificate = tostring(get_env("ATLANTIS_CERTIFICATE", "notsosecret"))
  pem_private_key = tostring(get_env("ATLANTIS_PRIVATE_KEY", "notsosecret"))
}
