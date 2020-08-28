# Module off/on
variable "module_gcp" {
  description = "should we enable gcp module"
  default     = false
}

variable "module_k8s" {
  description = "should we enable k8s module"
  default     = false
}

variable "module_kv" {
  description = "should we enable kv module"
  default     = false
}

variable "module_ssh" {
  description = "should we enable ssh module"
  default     = false
}

# Namespace where to onboard our Application
variable "namespace" {
  description = "namespace where all work will happen"
}

# Kubernetes
variable "kubernetes_host" {
  description = "Kubernetes API endpoint"
}

variable "kubernetes_namespace" {
  description = "Kubernetes namespace"
  default     = "default"
}

variable "kubernetes_sa" {
  description = "Kubernetes service account"
  default     = "default"
}

variable "kubernetes_ca_cert" {
  description = "Kubernetes CA"
}

variable "token_reviewer_jwt" {
  description = "Kubernetes Auth"
}

# Kubernetes Policy
variable "policy_name" {
  description = "Name of the policy to be created"
}

variable "policy_code" {
  description = "Content of the policy to be created"
}

# Vault Provider Configuration
variable "role_id" {}
variable "secret_id" {}

variable "app_role_mount_point" {
  description = "Mount point of AppRole secret engine"
  default     = "app"
}

variable "default_lease_ttl_seconds" {
  description = "Default duration of lease validity"
  default     = 3600
}

variable "max_lease_ttl_seconds" {
  description = "Maximum duration of lease validity"
  default     = 10800
}

# SSH Secret Engine
variable "ssh_ca_allowed_users" {
  description = "comma-separated list of usernames that are to be allowed for CA based Auth"
  default     = "sebastien"
}

variable "ssh_otp_allowed_users" {
  description = "comma-separated list of usernames that are to be allowed for OTP based Auth"
  default     = "sebastien"
}

# GCP Secret Engine
variable "gcp_credentials" {
  description = "Credentials for GCP auth backend"
}

variable "gcp_role_name" {
  description = "Role name of GCP auth backend"
}

variable "gcp_bound_zones" {
  description = "List of zones that a GCE instance must belong to"
  type        = list(string)
}

variable "gcp_bound_projects" {
  description = "An array of GCP project IDs to restrict authentication to them"
  type        = list(string)
}

variable "gcp_token_policies" {
  description = "List of policies to encode onto generated tokens"
  type        = list(string)
}

variable "gcp_token_ttl" {
  description = "Incremental lifetime for generated tokens in number of seconds"
  type        = number
}

variable "gcp_token_max_ttl" {
  description = "Maximum lifetime for generated tokens in number of seconds"
  type        = number
}

