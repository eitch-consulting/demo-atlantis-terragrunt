variable "project" {
  description = "Project ID to use"
  type        = string
}

variable "name" {
  description = "Name of the certificate"
  type        = string
}

variable "description" {
  description = "Description for this certificate"
  type        = string
  default     = null
}

variable "scope" {
  description = "The scope of the certificate. DEFAULT: Served from core Google data centers. EDGE_CACHE: served from Edge Points of Presence. ALL_REGIONS: served from all GCP regions."
  type        = string
  default     = "DEFAULT"
}

variable "pem_certificate" {
  description = "The certificate string in PEM format"
  type        = string
}

variable "pem_private_key" {
  description = "The private key for the certificate in PEM format"
  type        = string
  sensitive   = true
}
