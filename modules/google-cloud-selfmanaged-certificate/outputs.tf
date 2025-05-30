output "id" {
  description = "An identifier for the resource with format projects/{{project}}/locations/{{location}}/certificates/{{name}}"
  value       = google_certificate_manager_certificate.default.id
}

output "san_dnsnames" {
  description = "The list of Subject Alternative Names of dnsName type defined in the certificate (see RFC 5280 4.2.1.6)"
  value       = google_certificate_manager_certificate.default.san_dnsnames
}

output "map_id" {
  description = "An indenfitifer for the MAP resource with format projects/{{project}}/locations/global/certificateMaps/{{name}}"
  value       = google_certificate_manager_certificate_map.default.id
}

output "map_entry_id" {
  description = "An indenfitifer for the MAP ENTRY resource with format projects/{{project}}/locations/global/certificateMaps/{{map}}/certificateMapEntries/{{name}}"
  value       = google_certificate_manager_certificate_map_entry.default.id
}
