# mounting gcp auth backend
#resource "vault_auth_backend" "gcp" {
#    path = "gcp"
#    type = "gcp"
#}
resource "vault_gcp_auth_backend" "gcp" {
    credentials  = var.gcp_credentials
}

# For all the details
# see docs @ https://registry.terraform.io/providers/hashicorp/vault/2.6.0/docs/resources/gcp_auth_backend_role
resource "vault_gcp_auth_backend_role" "gcp" {
    role                   = var.gcp_role_name
    type                   = "gce"
    backend                = "gcp"
    bound_projects         = var.gcp_bound_projects
    bound_zones            = var.gcp_bound_zones
    token_policies         = var.gcp_token_policies
    token_ttl              = var.gcp_token_ttl
    token_max_ttl          = var.gcp_token_max_ttl
}