module "policy" {
  source = "./policy"

  policy_name = var.policy_name
  policy_code = var.policy_code
}

module "kv" {
  source = "./kv"
}

module "k8s" {
  source = "./k8s"

  kubernetes_host = var.kubernetes_host
  kubernetes_ca_cert = var.kubernetes_ca_cert
  token_reviewer_jwt = var.token_reviewer_jwt
  policy_name = var.policy_name
}

module "ssh" {
  source = "./ssh"

  ssh_ca_allowed_users = var.ssh_ca_allowed_users
  ssh_otp_allowed_users = var.ssh_otp_allowed_users
}

module "gcp" {
  source = "./gcp"

  gcp_credentials = var.gcp_credentials
  bound_zones     = var.bound_zones
  bound_projects  = var.bound_projects
  token_policies  = var.token_policies
  token_ttl       = var.token_ttl
  token_max_ttl   = var.token_max_ttl
}