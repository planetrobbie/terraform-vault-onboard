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
  default = "default"
}

variable "kubernetes_sa" {
  description = "Kubernetes service account"
  default = "default"
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
  default = "app"
}

variable "default_lease_ttl_seconds" {
  description = "Default duration of lease validity"
  default = 3600
}

variable "max_lease_ttl_seconds" {
  description = "Maximum duration of lease validity"
  default = 10800
}