variable "ssh_path" {
  description = "ssh secret engine mount point"
  default     = "ssh"
}

variable "ssh_ca_role" {
  description = "ssh secret engine CA role"
  default     = "ca"
}

variable "ssh_ca_allowed_users" {
  description = "Specifies a comma-separated list of usernames that are to be allowed for CA based Auth, only if certain usernames are to be allowed."
  default     = "ubuntu"
}

variable "ssh_ca_default_extensions" {
  type        = map(string)
  description = "Specifies a map of extensions that certificates have when signed"
  default     =  {
      permit-pty: ""
      permit-port-forwarding: ""
    }
}

variable "ssh_ca_ttl" {
  description = "Specifies the maximum Time To Live value."
  default     = "300"
}

variable "ssh_otp_role" {
  description = "ssh secret engine OTP role"
  default     = "otp"
}

variable "ssh_otp_allowed_users" {
  description = "Specifies a comma-separated list of usernames that are to be allowed for OTP based Auth, only if certain usernames are to be allowed."
  default     = "ubuntu"
}

variable "ssh_otp_default_user" {
  description = "Specifies the default username for which a credential will be generated"
  default     = "ubuntu"
}

variable "ssh_otp_cidr_list" {
  description = "The comma-separated string of CIDR blocks for which this role is applicable"
  default     = "0.0.0.0/0"
}