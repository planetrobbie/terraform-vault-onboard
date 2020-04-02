# Introduction

Project onboarding automation on HashiCorp Vault Enterprise using Terraform Vault provider.

By leveraging the code in this repository you can automated the configuration of your HashiCorp Vault Cluster to enable the following use cases

* Authenticate application running in Kubernetes Pods
* Authenticate instances running on Google Cloud Platform
* OpenSSH access to instances using Vault SSH secret engine
* Automate Instance onboarding to Vault SSH Secret Engine
 
To support these use cases this code also

* Create a Vault namespace [require HashiCorp Vault Enterprise]
* Create an AppRole auth backend for Terraform Vault Provider
* Configure Vault policies
* Mount a K/V Secret Engine

And more to come !!! stay tuned ;)

## Requirements:

* [Terraform 0.12](https://www.terraform.io/)
* [Terraform Vault provider](https://www.terraform.io/docs/providers/vault/index.html)
* [Vault Enterprise](https://www.hashicorp.com/products/vault/enterprise)
* [Kubernetes cluster](https://learn.hashicorp.com/vault/identity-access-management/vault-agent-k8s)
* [Google Cloud Project](https://console.cloud.google.com)
 
## Setup

First of all you need to export the following environment variables in your shell environment. But if you're using Terraform Cloud or Enterprise you can easily do so from the UI, just remove `TF_VAR_`. When setting them up in Terraform Cloud or Enterprise, just keep the variable name itself.

So if you're using Terraform Open Source, just export values for the following environment variables, we've kept some default values, feel free to change any of them.

### Configure Vault variables

You need to have administrative privileges on your Vault cluster which would allow you to create namespace and mount an AppRole auth backend and generate a Role ID and Secret ID for Terraform. To do that, you can export the following main environment variables.

    export VAULT_ADDR="https://VAULT_API_ENDPOINT"
    export VAULT_TOKEN="<VAULT_TOKEN>"

You'll find all the remaining environment variables gathered into `set-example.sh`, edit this file to customize it to your wishes. If you comment out some of them, if you don't want the corresponding use cases, don't forget to comment out the matching Terraform code. I'll implement conditional modules as soon as it will become available in Terraform 0.13.

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

### Configure Kubernetes variables

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

### Configure Google Auth Backend variables

The most important variable is your Google credentials, just paste in your `set.sh` below

    # GCP Auth backend
    export TF_VAR_gcp_credentials=$(cat <<EOF
    <GOOGLE CLOUD CREDENTIALS HERE>
    EOF
    )

### Export Environment variables

Make sure your kubernetes cluster is up and running and export all of the above environment variables.

    source set.sh

## Create your namespace

We want to restrict Terraform to a namespace to limit the blast radius. So First things first, we initially need a namespace. Create it like that

    cd namespace
    terraform init
    terraform apply

If that doesn't work, it's simply because you haven't exported `VAULT_ADDR` and `VAULT_TOKEN` environment variable to allow our Terraform Vault provider to authenticate.

If it fails at the init step, you may not have internet access, in such a case you have to install the [Terraform Vault provider](https://www.terraform.io/docs/providers/vault/index.html) manually in `~/.terraform.d/plugins`, it's available for all supported platforms below

    https://releases.hashicorp.com/terraform-provider-vault/2.9.0/

## Enable AppRole Auth Backend

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

End this section by grabbing the above output to update the following last two variables in your `set-example.sh`

    export TF_VAR_role_id="<ROLE_ID>"
    export TF_VAR_secret_id="<SECRET_ID>"

Note: Secret ID above is a highly sensitive variable, make sure you don't keep the corresponding command line in your shell history.

## Final provisioning.

Before you can run the overall provisionning within the created namespace you need to source your set-example to inject the role_id and secret_id created in the previous step

    source set-example.sh

You're now ready for the real deal. Go back to the root of this project and run terraform

    cd ..
    terraform init
    terraform apply

Everything should now be ready for applications to consume this namespace secrets.

## Testing

### Kubernetes Authentication

To verify that everything went according to plan, launch a minimal pod 

    kubectl run test --rm -i --tty \
    --env="VAULT_ADDR=https://<VAULT_IP>:<VAULT_PORT>" \
    --image alpine:latest -- /bin/sh

in the corresponding Kubernetes namespace and run inside it

    apk update; apk add curl jq
    JWT=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
    curl -k --request POST \
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

### Google Cloud Authentication

To verify that your GCP Auth backend is correctly configured, launch an instance which qualify, zone and project should match. Once you're inside it, first grab your JWT token

    export JWT_TOKEN="$(curl -sS -H 'Metadata-Flavor: Google' --get --data-urlencode 'audience=http://vault/<GCP_ROLE_NAME>' --data-urlencode 'format=full' 'http://metadata/computeMetadata/v1/instance/service-accounts/default/identity')" 

Note: make sure you've updated your role name in the command above.

You should now be able to authenticate

    export VAULT_ADDR=https://<VAULT_API>
    vault write auth/gcp/login role="<GCP_ROLE_NAME>" jwt="$JWT_TOKEN"

or thru the API

     curl \
       --request POST \
       --data "{\"role\":\"<GPP_ROLE_NAME>\", \"jwt\": \"$JWT_TOKEN\"}" \
       https://<VAULT_API>/v1/auth/gcp/login | jq

## Troubleshooting

### SSH

To troubleshoot SSH related issues, you can check the content of your signed key online pasting it into

    https://gravitational.com/resources/ssh-certificate-parser/

Instead of getting back a token you may have a message saying

If everything looks good in your signed certificate but you still can connect investigate further by looking at the logs of the target machine

    tail -f /var/log/auth.log

You can also get more details by looking at the ssh daemon log

    sudo journalctl -fx -u ssh

We use `-f` to follow logs and `-x` to get more information.

### Kubernetes

When trying to authenticate if you get a message like

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

### Google Cloud Authentication

If you can't get your instance authenticated to Vault, make sure its zone and project match what you've configured within your GCP Auth backend role. Look at your role carefully and compare it with the instance details.

    vault read auth/gcp/role/<GCP_ROLE_NAME>

## Links

* HashiCorp Vault [documentation](https://learn.hashicorp.com/vault/identity-access-management/vault-agent-k8s)
* Kubernetes Tips: [Using a ServiceAccount](https://medium.com/better-programming/k8s-tips-using-a-serviceaccount-801c433d0023)