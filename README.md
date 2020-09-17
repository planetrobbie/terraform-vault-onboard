## Introduction

This project will give you all the bits and pieces to automate the following [Vault Enterprise](https://www.hashicorp.com/products/vault) use cases using [Terraform Enterprise](https://www.hashicorp.com/products/terraform) or [Terraform Cloud](https://www.terraform.io/docs/cloud/overview.html) [API](https://www.terraform.io/docs/cloud/api/index.html):

* Store static secrets encrypted in a K/V store
* Authenticate application running in Kubernetes Pods
* Authenticate instances running on Google Cloud Platform
* OpenSSH access to instances using Vault SSH secret engine
* Automate Instance onboarding to Vault SSH Secret Engine
 
This is possible by leveraging HashiCorp [Terraform Vault provider](https://registry.terraform.io/providers/hashicorp/vault/latest/docs). 

To achieve that goal we will automate the following operations 

* Creation of a Vault namespace [require HashiCorp Vault Enterprise]
* Creation of an AppRole auth backend for Terraform Vault Provider
* Configuration of Vault policies
* Mounting a K/V Secret Engine
* And more to come !!! stay tuned ;)

This repository is for demonstration purpose but could be extended to support production workflows. We will be using [Postman](https://www.postman.com/) to automate the overall workflow, Postman will cascade all the Terraform Enterprise (TFE) or Cloud (TFC) API calls but any other orchestrator could also be leveraged to reach the same goal.

## Disclaimer

Interacting with Vault from Terraform causes any secrets that you read and write to be persisted in both Terraform's state file and in any generated plan files. For any Terraform module that reads or writes Vault secrets, these files should be treated as sensitive and protected accordingly.

As of today both Terraform Cloud and Enterprise store the state file encrypted and restrict who can get access to the cleartext version. But that may not be enough, in such a case we advice to only drive the structure automation (namespacing, mounting secret engines, ...) using this workflow, the secret injection can be done out of band.

## Requirements:

* [Terraform 0.13.1+](https://www.terraform.io/)
* [Postman](https://www.postman.com/)
* [Terraform Vault provider](https://www.terraform.io/docs/providers/vault/index.html)
* [Vault Enterprise](https://www.hashicorp.com/products/vault/enterprise)
* [Terraform Cloud account](https://app.terraform.io/session) or [Terraform Enterprise](https://www.terraform.io/docs/enterprise/index.html)
 
## Optional requirements:

* [Kubernetes cluster](https://learn.hashicorp.com/vault/identity-access-management/vault-agent-k8s)
* [Google Cloud Project](https://console.cloud.google.com)
 
## Import Postman Collection

First of all you need to import the following three collections to Postman.

- [Vault TFE Onboarding](https://github.com/planetrobbie/terraform-vault-onboard/blob/master/postman/vault_tfe_onboarding.postman_collection.json) - onboard everything from scratch
- [Vault TFE Day 2](https://github.com/planetrobbie/terraform-vault-onboard/blob/master/postman/vault_tfe_day2.postman_collection.json) - example of how to add/remove secret engines from Vault namespace using latest count features from Terraform 0.13.
- [Vault TFE Clean](https://github.com/planetrobbie/terraform-vault-onboard/blob/master/postman/vault_tfe_clean.postman_collection.json) - Clean everything out

You can read Postman documentation for this step on their [documentation site](https://learning.postman.com/docs/getting-started/importing-and-exporting-data/#importing-postman-data)

Once its done, update the following Collection variables from the different collections to suit to your needs:

- `project_name` replace PROJECT_NAME with the name of your project, it will be use to prepend all TFC/TFE workspace with that name, to avoid name collision.

- `tfe` API endpoint, edit your collection Variables to replace `https://TFE_API_URL` with your TFC or TFE API endpoint. If you use TFC just put instead `https://app.terraform.io` leave the `api/v2` at the end.

- `tfe_token` which will give Postman the credentials to authenticate to Terraform Cloud (TFC) or Terraform Enterprise (TFE). Replace `TFE_TOKEN` with your token. To see how to generate such an API Token, consult our [Documentation](https://www.terraform.io/docs/cloud/users-teams-organizations/api-tokens.html)

- `tfe_org` TFE/TFC Organisation, replace `ORG` with your own organisation.

- `vault` replace `https://VAULT_API_URL` with your Vault API endpoint URL.

- `vault_token` replace `VAULT_TOKEN` with a vault token with enough priviledges to create a namespace, create policies, mount and configure a [AppRole](https://www.vaultproject.io/docs/auth/approle) Auth backend.

- `vault_namespace` replace `VAULT_NAMESPACE` with the [Vault namespace](https://www.vaultproject.io/docs/enterprise/namespaces) you want Postman to create.

- `vcs_identifier` replace `VCS_IDENTIFIER` by the location of the mirror of this repository, for example in my case it's `planetrobbie/terraform-vault-onboard`

- `vcs_oauth-token-id` replace `OAUTHID` with your version control system oAuthID, generated when you've connected your VCS with TFC/TFE, check our [docs](https://www.terraform.io/docs/cloud/vcs/github.html)

We've limited ourselves above to the main and mandatory variables. Below you'll find some more details regarding optional parameters that you can tweak if required.

## Initial onboarding

Without further due you should now be able to run your Onboarding collection which will:

- create `{{project_name}}-vault-namespace` TFC/TFE workspace and set variables
- create `{{project_name}}-vault-approle` TFC/TFE workspace and set variables
- create `{{project_name}}-vault-onboarding` TFC/TFE workspace and set variables

And then, plan/apply all of the above workspaces which will result in the creation and configuration of the `{{vault_namespace}}`

## Day 2 operations

The second collection you could use, *Vault TFE Day 2*, is leveraging the capability of terraform 0.13+ to optionally add a module based on a `count` parameter to demonstrate how an additional Vault Secret Engine can be added to an existing namespace.

To demonstrate that feature, you just have to grab the workspace identifier from TFE/TFC setting of the `{{project_name}}-vault-onboarding` workspace and update accordingly the Postman collection variable `id_ws_vault_onboarding`

For example if you use Terraform Cloud, you just have to reach the following URL (replace your `ORG` and `project_name`  below)

https://app.terraform.io/ORG/workspaces/{{project_name}}-vault-onboarding/settings/general

You can then run the different API calls from this collection to see how a SSH secret engine can be added and then removed from Vault.

## Cleaning out everything

To end this demo, you can finally run the *Vault TFE Clean* Postman collection which will clean all of the workspaces and the vault namespace leaving nothing behind.

Thanks for trying our Terraform Enterprise API based Vault Onboarding workflow. I hope it was useful.

### Optional variables

Below we details many more variables you could inject in your TFC/TFE Onboarding workspace to tune the way this repository works for you.

`app_role_mount_point` Where to mount AppRole auth backend
`role_name` AppRole role name
`kv_path` Path where to mount a Key/Value Vault Secret Engine
`k8s_path` Path where to mound a Kubernetes Auth Backend

They all have a default value, so it's your call if you want to change them in any way shape or form.

### Kubernetes related variables

`kubernetes_host` Kubernetes API endpoint for example https://api.k8s.foobar.com
`VAULT_SA_NAME` can be set with `$(kubectl get sa vault-auth -o jsonpath="{.secrets[*]['name']}")`

Replace in the line above `vault-auth` by the service account name you're using for your Kubernetes Vault integration. See our [article](https://learn.hashicorp.com/vault/identity-access-management/vault-agent-k8s) for details.

The next two variables allows Vault to verify the token that Kubernetes Pods sends.

`token_reviewer_jwt` can be set using `$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data.token}" | base64 --decode; echo)`
`kubernetes_ca_cert` can be set using `$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data['ca\.crt']}" | base64 --decode; echo)`

policy which will be associated with each authenticated Pods.

`policy_name` Kubernetes Vault Policy name to be creation
`policy_code` Kubernetes Vault Policy JSON definition

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

`gcp_credentials` your Google credentials which should be declared sensitive in TFC/TFE.

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
