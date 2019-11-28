# VM Instance SSH CA automation

This Project will allow you to build an image containing all the required moving parts to automate SSH CA onboarding.

Once you boot a compute instance, it will automatically grab the SSH CA from Vault after an auto_auth provided by Google Cloud Auth backend.

All of that by achieved by the magical vault agent 1.3.0 which integrates Consul-template features to generate configuration files automagically from Vault API.

To jumpstart this process, first download the Vault binary in `ssh-automation/packer/files/`

    curl https://releases.hashicorp.com/vault/1.3.0/vault_1.3.0_linux_amd64.zip --output ssh-automation/packer/files/

Also install your Vault `ca.crt` into the same `ssh-automation/packer/files/` directory

Copy `config.hcl.example` and update it with your VAULT_API URL

    cp ssh-automation/packer/files/config.hcl.example ssh-automation/packer/files/config.hcl
    vi ssh-automation/packer/files/config.hcl

Copy and customise the packer build of your choice. If you want to push the binary to the image yourself 

    cp ssh-automation/packer/vault-image.json.example ssh-automation/packer/vault-image.json

If you prefer the instance to do the download itself

    cp ssh-automation/packer/vault-image-pull.json.example ssh-automation/packer/vault-image.json

Review what you have to update

    vi ssh-automation/packer/vault-image.json

Once you've updated the corresponding `vault-image.json` file with your GCP project and zone, you can build your image

    cd ssh-automation/packer/
    packer build vault-image.json

The built image will have the following files ready to be consumed by your vault agent

* `/etc/vault/tls/ca.crt` Vault TLS Public Certificate
* `/etc/vault/config.hcl` Vault Agent configuration to grab the SSH CA file
* `/usr/local/bin/vault` Vault 1.3.0 binary

Packer have also added the following line to `/etc/ssh/sshd_config`

    TrustedUserCAKeys /etc/ssh/trusted-user-ca-keys.pem
 
# Provision an Instance

Now that you have an image ready, you can switch over to the provided terraform directory to provision an instance from it.

    cd ../terraform

Configure all the required variables from the example file

    cp terraform.tfvars.example terraform.tfvars
    vi terraform.tfvars

Make sure you updated the image variable with the image ID from the Packer build.

Once everything is ready, launch the privisionning.

    terraform apply -auto-approve

# Test

You should now be able to sign your ssh public key and connect to this instance. You can do all of that in a single step like this

    vault ssh -role <SSH_ROLE_NAME> -mode ca <USER>@<IP_FROM_TERRAFORM_OUTPUT> -namespace='<VAULT_NAMESPACE>'

Or step by step

    export VAULT_ADDR=https://<VAULT_API>
    export VAULT_NAMESPACE="<VAULT_NAMESPACE>"
    vault write -field=signed_key ssh/sign/<SSH_ROLE_NAME> public_key=@$HOME/.ssh/id_rsa.pub valid_principals=<USER> > ~/.ssh/id_rsa-cert.pub
    ssh <USER>@<IP_FROM_TERRAFORM_OUTPUT>

But if you don't have vault binary on your machine, you can also sign your key directly from Vault API

    export TOKEN=`cat ~/.vault-token`; curl -k -sS -X POST -H "X-Vault-Token: $TOKEN" https://<VAULT_API>/v1/ssh/sign/<SSH_ROLE_NAME> --data '{"public_key": "<SSH_PUB_KEY>"}' | jq '.data.signed_key' | sed 's/"//g' | sed 's/\\n//g'> ~/.ssh/id_rsa-cert.pub
    ssh <USER>@<IP_FROM_TERRAFORM_OUTPUT>

Once you are in the VM, you could check what both Packer and Terraform introduced to automate the process

Vault Agent configuration file

    cat /etc/vault/config.hcl

OpenSSH configuration which trusted Vault CA (last line)

    cat /etc/ssh/sshd_config

You can run Vault Agent manually to see how it works

    sudo vault agent -config=/etc/vault/config.hcl

You need to run it as root to allow it to write priviledged files like the trustedCA into `/etc/ssh/trusted-user-ca-keys.pem`

Congratulation, you now have an environment to automatically onboard your instances to your SSH Secret Engine within your Vault namespace.