terraform_version_constraint  = ">= 1.12.0"
terragrunt_version_constraint = ">= 0.80.4"

locals {
  repo_root = get_path_to_repo_root()

  project_vars  = read_terragrunt_config(find_in_parent_folders("project.hcl")).locals
  region_vars   = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals
  provider_vars = read_terragrunt_config(find_in_parent_folders("provider.hcl")).locals

  region    = can(local.region_vars.region) ? local.region_vars.region : "global"
  providers = local.provider_vars.providers

  provider_project = format("project = \"%s\"", local.project_vars.project_id)
}

generate "google_cloud_provider" {
  path      = "_tg-providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    %{if contains(local.providers, "google")}
    provider "google" {
      region = "${local.region}"

      add_terraform_attribution_label               = true
      terraform_attribution_label_addition_strategy = "PROACTIVE"

      ${local.provider_project}
    }
    %{endif}
    %{if contains(local.providers, "acme")}
    provider "acme" {
      # let's encrypt production
      server_url = "https://acme-v02.api.letsencrypt.org/directory"

      # let's encrypt staging
      #server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"

      # zerossl production
      #server_url = "https://acme.zerossl.com/v2/DV90"
    }
    %{endif}
  EOF
}

# Configure Terragrunt to automatically store tfstate files in a Storage Bucket
remote_state {
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  backend = "gcs"

  config = {
    bucket = format("tfstate-%s-%s", local.project_vars.project_number, local.project_vars.project_id)
    prefix = format("%s", path_relative_to_include())
  }
}

inputs = merge(
  local.project_vars,
  local.region_vars,
  local.provider_vars,
)
