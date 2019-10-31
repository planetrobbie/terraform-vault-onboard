provider "vault" {
  # $VAULT_ADDR should be configured with the endpoint where to reach Vault API.
  # Or uncomment and update following line
  # address = "https://<VAULT_API>"

  namespace = var.namespace
  
  # Authenticate using AppRole within our namespace
  auth_login {
    path = "${var.namespace}/auth/${var.app_role_mount_point}/login"
    parameters = {
      role_id = var.role_id
      secret_id = var.secret_id
    }
  }
}