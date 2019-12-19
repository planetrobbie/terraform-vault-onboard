# GCP Secret Engine
variable "gcp_credentials" {
  description = "Credentials for GCP auth Backend"
}

variable "gcp_role_name" {
  description = "GCP Auth role name"
}

variable "gcp_bound_zones" {
  description = "List of zones that a GCE instance must belong to"
  type = list(string)
}

variable "gcp_bound_projects" {
  description = "An array of GCP project IDs to restrict authentication to them"
  type = list(string)
}

variable "gcp_token_policies" {
  description = "List of policies to encode onto generated tokens"
  type = list(string)
}

variable "gcp_token_ttl" {
  description = "Incremental lifetime for generated tokens in number of seconds"
  type = number
}

variable "gcp_token_max_ttl" {
  description = "Maximum lifetime for generated tokens in number of seconds"
  type = number
}