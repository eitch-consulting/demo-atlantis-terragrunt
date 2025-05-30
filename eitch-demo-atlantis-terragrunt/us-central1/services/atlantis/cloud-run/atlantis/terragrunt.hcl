terraform {
  source = "tfr:///GoogleCloudPlatform/cloud-run/google?version=0.17.4"
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
    format("%s/_global/infrastructure/vpc", dirname(find_in_parent_folders("project.hcl"))),
    format("%s/_global/services/atlantis/sa/atlantis", dirname(find_in_parent_folders("project.hcl"))),
    format("%s/_global/services/atlantis/secrets/ATLANTIS", dirname(find_in_parent_folders("project.hcl"))),
    format("%s/artifact-registry/demo", dirname(find_in_parent_folders("service.hcl")))
  ]
}

dependency "vpc" {
  config_path = format("%s/_global/infrastructure/vpc", dirname(find_in_parent_folders("project.hcl")))
}

dependency "sa" {
  config_path = format("%s/_global/services/atlantis/sa/atlantis", dirname(find_in_parent_folders("project.hcl")))
}

inputs = {
  service_name = "atlantis"
  project_id   = local.project_vars.project_id
  location     = local.region_vars.location
  image        = "us-central1-docker.pkg.dev/eitch-demo-atlantis-terragrunt/demo/atlantis-terragrunt:0.34.0-2"

  #image = "us-docker.pkg.dev/cloudrun/container/hello"

  container_concurrency = 1
  timeout_seconds       = 60
  service_account_email = dependency.sa.outputs.email

  ports = {
    name : "http1",
    port : "4141"
  }

  members = [
    "allUsers"
  ]

  limits = {
    cpu    = "1",
    memory = "4G"
  }

  startup_probe = {
    timeout_seconds   = "30",
    period_seconds    = "60"
    failure_threshold = "1"
    tcp_socket = {
      port = "4141"
    }
  }

  service_annotations = {
    "run.googleapis.com/ingress" = "internal-and-cloud-load-balancing"
  }

  template_annotations = {
    "autoscaling.knative.dev/maxScale" = "1"
    "autoscaling.knative.dev/minScale" = "0"
    "run.googleapis.com/network-interfaces" = jsonencode(
      [
        {
          "network"    = "${dependency.vpc.outputs.network_name}",
          "subnetwork" = "${local.region_vars.region}",
          "tags"       = ["atlantis"]
        }
      ]
    )
    "run.googleapis.com/vpc-access-egress"     = "private-ranges-only"
    "run.googleapis.com/cpu-throttling"        = "false"
    "run.googleapis.com/startup-cpu-boost"     = "true"
    "run.googleapis.com/execution-environment" = "gen2"
  }

  template_labels = {
    "run.googleapis.com/startupProbeType" = "Custom"
  }

  env_secret_vars = [
    {
      name = "ATLANTIS_GH_APP_KEY"
      value_from = [{
        secret_key_ref = {
          key  = "latest"
          name = "ATLANTIS_GH_APP_KEY"
        }
      }]
    },
    {
      name = "ATLANTIS_GH_WEBHOOK_SECRET"
      value_from = [{
        secret_key_ref = {
          key  = "latest"
          name = "ATLANTIS_GH_WEBHOOK_SECRET"
        }
      }]
    },
    {
      name = "ATLANTIS_WEB_PASSWORD"
      value_from = [{
        secret_key_ref = {
          key  = "latest"
          name = "ATLANTIS_WEB_PASSWORD"
        }
      }]
    }
  ]

  env_vars = [
    {
      name  = "ATLANTIS_ATLANTIS_URL"
      value = "https://atlantis.eitch-consulting.com"
    },
    {
      name  = "ATLANTIS_GH_APP_ID"
      value = "1344485"
    },
    {
      name  = "ATLANTIS_GH_ORG"
      value = "eitch-consulting"
    },
    {
      name  = "ATLANTIS_REPO_ALLOWLIST"
      value = "github.com/eitch-consulting/demo-atlantis-terragrunt"
    },
    {
      name  = "ATLANTIS_VCS_STATUS_NAME"
      value = format("atlantis/%s", local.project_vars.project_id)
    },
    {
      name  = "ATLANTIS_AUTOMERGE"
      value = true
    },
    {
      name  = "ATLANTIS_DISABLE_APPLY_ALL"
      value = true
    },
    {
      name  = "ATLANTIS_DISABLE_AUTOPLAN"
      value = false
    },
    {
      name  = "ATLANTIS_CHECKOUT_STRATEGY"
      value = "merge"
    },
    {
      name  = "ATLANTIS_LOG_LEVEL"
      value = "info"
    },
    {
      name  = "ATLANTIS_EMOJI_REACTION"
      value = "eyes"
    },
    {
      name  = "ATLANTIS_WEB_BASIC_AUTH"
      value = "true"
    },
    {
      name  = "ATLANTIS_WRITE_GIT_CREDS"
      value = "true"
    },
    {
      name  = "TG_PROVIDER_CACHE"
      value = "true"
    },
    {
      name  = "TF_PLUGIN_CACHE_MAY_BREAK_DEPENDENCY_LOCK_FILE"
      value = "true"
    }
  ]
}
