variable "project" {
  description = "Project ID to use"
  type        = string
}

variable "name" {
  description = "Name of the NEG endpoint"
  type        = string
}

variable "network_endpoint_type" {
  description = "Type of network endpoints in this network endpoint group. Possible values are: SERVERLESS, PRIVATE_SERVICE_CONNECT, INTERNET_IP_PORT, INTERNET_FQDN_PORT."
  type        = string
  default     = "SERVERLESS"
}

variable "region" {
  description = "Region where the network endpoint group is located."
  type        = string
}

variable "cloud_run_service" {
  description = "Name of the cloud run service to be assigned the NEG."
  type        = string
  default     = null
}

variable "cloud_run_url_mask" {
  description = "A template to parse service and tag fields from a request URL."
  type        = string
  default     = null
}
