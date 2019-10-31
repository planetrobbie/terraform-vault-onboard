# mounting kv secret engine
resource "vault_mount" "kv" {
  path        = var.kv_path
  type        = "kv"
  description = "kv secret engine managed by Terraform"
}

# storing secret
resource "vault_generic_secret" "secret" {
  path = var.secret_path
  data_json = var.secret_data

  depends_on = [vault_mount.kv]
}