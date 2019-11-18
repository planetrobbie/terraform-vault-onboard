# Introduction

Project onboarding automation on HashiCorp Vault Enterprise using Terraform Vault provider.

## Requirements:

* [Terraform 0.12](https://www.terraform.io/)
* [Terraform Vault provider](https://www.terraform.io/docs/providers/vault/index.html)
* [Vault Enterprise](https://www.hashicorp.com/products/vault/enterprise)
* [Kubernetes cluster](https://learn.hashicorp.com/vault/identity-access-management/vault-agent-k8s)

## Setup

First of all you need to export the following environment variables in your shell environment. But if you're using Terraform Cloud or Enterprise you can easily do so from the UI, just remove `TF_VAR_`. When setting them up in Terraform Cloud or Enterprise, just keep the variable name itself.

So if you're using Terraform Open Source, just export values for the following environment variables, we've kept some values, feel free to change any of them.

### Vault variables

You need to have administrative privileges on your Vault cluster which would allow you to create namespace and mount an AppRole auth backend and generate a Role ID and Secret ID for Terraform. To do that, you can export the following environment variables. You'll find an example in the file ```set-example.sh```.

    export VAULT_ADDR="https://VAULT_API_ENDPOINT"
    export VAULT_TOKEN="<VAULT_TOKEN>"

Then export all the following variables.

Namespace where your project onboarding will take place
    
    export TF_VAR_namespace

Where to mount AppRole auth backend

    export TF_VAR_app_role_mount_point

AppRole role name

    export TF_VAR_role_name

Path where to mount a Key/Value Vault Secret Engine

    export TF_VAR_kv_path

Path where to mound a Kubernetes Auth Backend

    export TF_VAR_k8s_path 

### Kubernetes variables

    TF_VAR_kubernetes_host: Kubernetes API endpoint for example https://api.k8s.foobar.com
    VAULT_SA_NAME: $(kubectl get sa vault-auth -o jsonpath="{.secrets[*]['name']}")

Replace in the line above `vault-auth` by the service account name you're using for your Kubernetes Vault integration. See our [article](https://learn.hashicorp.com/vault/identity-access-management/vault-agent-k8s) for details.

The next two variables allows Vault to verify the token that Kubernetes Pods sends.

    TF_VAR_token_reviewer_jwt=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data.token}" | base64 --decode; echo)
    TF_VAR_kubernetes_ca_cert=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data['ca\.crt']}" | base64 --decode; echo)

Now we can define a policy which will be associated with each authenticated Pods.

    TF_VAR_policy_name: Kubernetes Vault Policy name to be creation
    TF_VAR_policy_code: Kubernetes Vault Policy JSON definition

As a example you could have in the above variable something like

    $(cat <<EOF
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

## Namespace

We want to restrict Terraform to a namespace to limit the blast radius. So First things first, we initially need a namespace. Create it like that

    cd namespace
    terraform init
    terraform apply

If that doesn't work, it's simply because you haven't exported `VAULT_ADDR` and `VAULT_TOKEN` environement variable to allow our Terraform Vault provider to authenticate.

## AppRole Auth Backend

Now that we have our namespace created above, we've configured Terraform Vault Provider to act on it, See the definition below in `approle/main.tf`

    provider "vault" {
        # $VAULT_ADDR should be configured with the endpoint where to reach Vault API.
        # Or uncomment and update following line
        # address = "https://vault.prod.yet.org"
        namespace = var.namespace
    }

We'll now create an AppRole within that namespace for Terraform Vault provider to authenticate within it.

You can first run the following commands to mount and create a secret. 

    cd ../approle
    terraform init
    terraform apply

End this section by grabbing the above output to update the following last two variables

    export TF_VAR_role_id="<ROLE_ID>"
    export TF_VAR_secret_id="<SECRET_ID>"

Note: Secret ID above is a highly sensitive variable, make sure you don't keep the corresponding command line in your shell history.

## Final provisioning.

You're now ready for the real deal. Go back to the root of this project and run terraform

    cd ..
    terraform apply

Everything should now be ready for applications to consume this namespace secrets.

## Testing

To verify that everything went according to plan, launch a minimal pod 

    kubectl run test --rm -i --tty \
    --env="VAULT_ADDR=https://<VAULT_IP>:<VAULT_PORT>" \
    --image alpine:latest -- /bin/sh

in the corresponding Kubernetes namespace and run inside it

    apk update; apk add curl jq
    JWT=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
    curl --request POST \
         --header "X-Vault-Namespace: <YOURNAMESPACE>" \
         --data '{"jwt": "'"$JWT"'", "role": "<YOURROLE>"}' \
        $VAULT_ADDR/v1/auth/k8s/login | jq

You should get back a token from Vault.

Alternatively you can launch a vault pod which makes it even simpler

    JWT=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
    kubectl run vault-shell --rm -i --tty \
    --env="VAULT_ADDR=https://<VAULT_API>" \
    --image vault:latest -- /bin/sh
    vault write -tls-skip-verify auth/kubernetes/login role=<ROLE> jwt=$JWT

If you grab the kubernetes token you can authenticate using vault

    vault write auth/kubernetes/login role=<ROLE> jwt=<TOKEN>

## Troubleshooting

To troubleshoot SSH related issues, you can check the content of your signed key online pasting it into

    https://gravitational.com/resources/ssh-certificate-parser/

Instead of getting back a token you may have a message saying

    * service account name not authorized

It is mostly probably due to a wrong role setup, make sure the role allows the service account under which the pod is running. If you don't have a line in your manifest saying

    serviceAccountName: <SERVICE_ACCOUNT>

Your pod will run under `default`, so your role needs to be configured with

    bound_service_account_names=default

or to allow all

    bound_service_account_names=*

If you want to check under which service account your pod is running you can use

    kubectl get po/<POD_NAME> -o yaml | grep serviceAccount

If that's not the service account which is causing issues it could also be the namespace, check that with

    kubectl get po/<POD_NAME> -o yaml | grep namespace

The Vault k8s role definition should match both service account and namespace, verify that with

     vault read -namespace=<VAULT_NAMESPACE>  auth/<k8s_auth_mount_point>/role/<ROLE>

## Links

* HashiCorp Vault [documentation](https://learn.hashicorp.com/vault/identity-access-management/vault-agent-k8s)
* Kubernetes Tips: [Using a ServiceAccount](https://medium.com/better-programming/k8s-tips-using-a-serviceaccount-801c433d0023)