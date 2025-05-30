terraform {
  source = "tfr:///terraform-google-modules/network/google?version=11.1.1"
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
    format("%s/account", dirname(find_in_parent_folders("service.hcl")))
  ]
}

inputs = {
  project_id   = local.project_vars.project_id
  network_name = local.project_vars.environment
  routing_mode = "REGIONAL"

  auto_create_subnetworks = false
  enable_ipv6_ula         = false
  shared_vpc_host         = false
  mtu                     = 1460

  subnets = [
    {
      subnet_name      = "us-central1"
      subnet_ip        = "10.128.0.0/20"
      subnet_region    = "us-central1"
      subnet_flow_logs = false
      stack_type       = "IPV4_ONLY"
    }
  ]

  routes = [
    {
      name              = "default-route-internet"
      description       = "Default route to the Internet."
      destination_range = "0.0.0.0/0"
      next_hop_internet = "true"
      priority          = "1000"
    }
  ]

  ingress_rules = [
    {
      name        = "alllow-icmp-ingress"
      description = "Allow ICMP traffic (ingress)"
      disabled    = false
      priority    = 500

      source_ranges = [
        "0.0.0.0/0"
      ]

      allow = [
        {
          protocol = "icmp"
        }
      ]
    },
    {
      name        = "alllow-http-https-ingress"
      description = "Allow HTTP and HTTPS traffic (ingress)"
      disabled    = false
      priority    = 500

      source_ranges = [
        "0.0.0.0/0"
      ]

      tags = [
        "atlantis"
      ]

      allow = [
        {
          protocol = "tcp"
          ports    = ["80", "443"]
        }
      ]
    },
    {
      name        = "deny-all-ingress"
      description = "Deny all ingress traffic"
      disabled    = false
      priority    = 10000

      source_ranges = [
        "0.0.0.0/0"
      ]

      deny = [
        {
          protocol = "tcp"
          ports    = ["0-65535"]
        },
        {
          protocol = "udp"
          ports    = ["0-65535"]
        }
      ]

    }
  ]

  egress_rules = [
    {
      name        = "allow-icmp-egress"
      description = "Allow ICMP Traffic (egress)"
      disabled    = false
      priority    = 500

      destination_ranges = [
        "0.0.0.0/0"
      ]

      allow = [
        {
          protocol = "icmp"
        }
      ]
    },
    {
      name        = "allow-atlantis-https-egress"
      description = "Allow atlantis egress for web (downloading modules/providers)"
      disabled    = false
      priority    = 500

      destination_ranges = [
        "0.0.0.0/0"
      ]

      target_tags = [
        "atlantis"
      ]

      allow = [
        {
          protocol = "tcp"
          ports    = ["443"]
        }
      ]
    },
    {
      name        = "deny-all-egress"
      description = "Deny all egress traffic"
      disabled    = false
      priority    = 10000

      destination_ranges = [
        "0.0.0.0/0"
      ]

      deny = [
        {
          protocol = "tcp"
          ports    = ["0-65535"]
        },
        {
          protocol = "udp"
          ports    = ["0-65535"]
        }
      ]
    },
  ]

  labels = local.service_vars.labels
}
