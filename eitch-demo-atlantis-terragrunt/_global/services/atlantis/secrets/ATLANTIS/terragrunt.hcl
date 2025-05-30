terraform {
  source = "tfr:///GoogleCloudPlatform/secret-manager/google?version=0.8.0"
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
  project_id = local.project_vars.project_id

  secrets = [
    {
      name        = "ATLANTIS_GH_APP_KEY"
      secret_data = tostring(get_env("ATLANTIS_GH_APP_KEY", "notsosecret"))
    },
    {
      name        = "ATLANTIS_GH_TOKEN"
      secret_data = tostring(get_env("ATLANTIS_GH_TOKEN", "notsosecret"))
    },
    {
      name        = "ATLANTIS_GH_WEBHOOK_SECRET"
      secret_data = tostring(get_env("ATLANTIS_GH_WEBHOOK_SECRET", "notsosecret"))
    },
    {
      name        = "ATLANTIS_WEB_PASSWORD"
      secret_data = tostring(get_env("ATLANTIS_WEB_PASSWORD", "notsosecret"))
    }
  ]

  labels = local.service_vars
}
