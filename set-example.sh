# AppRole for Terraform Vault provider authentication
export TF_VAR_app_role_mount_point="approle"
export TF_VAR_role_name="terraform"
export TF_VAR_role_id=""
export TF_VAR_secret_id=""

# Namespace
export TF_VAR_namespace="marketing"

# Policy
export TF_VAR_policy_name="k8s"
export TF_VAR_policy_code=$(cat <<EOF
path "kv/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "secret/data/apikey" {
  capabilities = ["read","list"]
}
path "db/creds/dev" {
  capabilities = ["read"]
}
path "pki_int/issue/*" {
  capabilities = ["create", "update"]
}
path "sys/leases/renew" {
  capabilities = ["create"]
}
path "sys/leases/revoke" {
  capabilities = ["update"]
}
path "sys/renew/*" {
  capabilities = ["update"]
}
EOF
)

# KV
export TF_VAR_kv_path="kv"

# Kubernetes
export TF_VAR_k8s_path="k8s"
export TF_VAR_kubernetes_host=""
export VAULT_SA_NAME=$(kubectl get sa vault-auth -o jsonpath="{.secrets[*]['name']}")
export TF_VAR_token_reviewer_jwt=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data.token}" | base64 --decode; echo)
export TF_VAR_kubernetes_ca_cert=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data['ca\.crt']}" | base64 --decode; echo)

# GCP Auth backend
export TF_VAR_gcp_credentials=$(cat <<EOF
<GOOGLE CLOUD CREDENTIALS HERE>
EOF
)
export TF_VAR_gcp_role_name="gce" 
export TF_VAR_gcp_bound_zones='["<YOUR_GCP_ZONE>"]'
export TF_VAR_gcp_bound_projects='["<YOUR_GCP_PROJECT>"]'
export TF_VAR_gcp_token_policies='["terraform"]'
export TF_VAR_gcp_token_ttl=1800
export TF_VAR_gcp_token_max_ttl=86400

# SSH Secret Engine
export TF_VAR_ssh_ca_allowed_users="ubuntu"
export TF_VAR_ssh_otp_allowed_users="ubuntu"
