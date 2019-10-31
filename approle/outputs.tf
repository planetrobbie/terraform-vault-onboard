output "namespace" {
  value = var.namespace
}

output "app_role_mount_point" {
  value = var.approle_path
}

output "role_name" {
  value = var.role_name
}

output "role_id" {
  value = vault_approle_auth_backend_role.terraform.role_id
}

output "secret_id" {
  value = vault_approle_auth_backend_role_secret_id.id.secret_id
}