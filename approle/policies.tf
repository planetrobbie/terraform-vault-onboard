resource "vault_policy" "terraform" {
  name = "terraform"

  policy = <<EOF
# Manage namespaces
path "sys/namespaces/*" {
   capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage policies
path "sys/policies/acl/*" {
   capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List policies
path "sys/policies/acl" {
   capabilities = ["list"]
}

# Enable Auth management
path "sys/auth" {
   capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Enable Kubernetes Auth mounting
path "sys/auth/${var.k8s_path}" {
   capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Enable and manage secrets engines
path "sys/mounts/*" {
   capabilities = ["create", "read", "update", "delete", "list"]
}

# Enable and manage secrets engines
path "sys/mounts" {
   capabilities = ["create", "read", "update", "delete", "list"]
}

# Create and manage entities and groups
path "identity/*" {
   capabilities = ["create", "read", "update", "delete", "list"]
}

# Manage tokens
path "auth/token/*" {
   capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Authorize k8s auth configuration
path "auth/${var.k8s_path}/config" {
   capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Authorize k8s role management within namespace
path "auth/${var.k8s_path}/role/*" {
   capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Allow TF to operate kv store
path "${var.kv_path}/*" {
   capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOF
}