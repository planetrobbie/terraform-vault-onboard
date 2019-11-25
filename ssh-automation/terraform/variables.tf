variable "vault_namespace" {
  description = "Vault Namespace from which to grab SSH CA"
  default = ""
}

variable "region" {
  description = "GCP region targeted"
  default = "europe-west1"
}

variable "region_zone" {
  description = "GCP zone targeted"
  default = "europe-west1-c"
}

variable "project_name" {
  description = "GCP project targeted"
}

variable "image" {
  description = "GCP Image to use"
}

variable "instance_type" {
  description = "GCP Machine Type to use"
  default = "f1-micro"
}