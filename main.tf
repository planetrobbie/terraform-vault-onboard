module "policy" {
  source = "./policy"

  policy_name = var.policy_name
  policy_code = var.policy_code
}

module "kv" {
  count  = var.module_kv
  source = "./kv"
}

module "k8s" {
  count  = var.module_k8s
  source = "./k8s"

  kubernetes_host    = var.kubernetes_host
  kubernetes_ca_cert = var.kubernetes_ca_cert
  token_reviewer_jwt = var.token_reviewer_jwt
  policy_name        = var.policy_name
}

module "ssh" {
  count  = var.module_ssh
  source = "./ssh"

  ssh_ca_allowed_users  = var.ssh_ca_allowed_users
  ssh_otp_allowed_users = var.ssh_otp_allowed_users
}

module "gcp" {
  count  = var.module_gcp
  source = "./gcp"

  gcp_credentials    = var.gcp_credentials
  gcp_role_name      = var.gcp_role_name
  gcp_bound_zones    = var.gcp_bound_zones
  gcp_bound_projects = var.gcp_bound_projects
  gcp_token_policies = var.gcp_token_policies
  gcp_token_ttl      = var.gcp_token_ttl
  gcp_token_max_ttl  = var.gcp_token_max_ttl
}
