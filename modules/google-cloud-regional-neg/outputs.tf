output "cloudrun_id" {
  description = "An identifier for the resource with format projects/{{project}}/regions/{{region}}/networkEndpointGroups/{{name}}"
  value       = length(google_compute_region_network_endpoint_group.cloudrun_neg) > 0 ? google_compute_region_network_endpoint_group.cloudrun_neg[0].id : null
}

output "cloudrun_self_link" {
  description = "The URI of the created resource."
  value       = length(google_compute_region_network_endpoint_group.cloudrun_neg) > 0 ? google_compute_region_network_endpoint_group.cloudrun_neg[0].self_link : null
}
