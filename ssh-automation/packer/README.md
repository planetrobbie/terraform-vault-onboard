# VM Instance SSH CA automation

To build an image containing all the required moving parts for it to automatically grab the SSH CA at boot time from Vault leveraging Google Cloud Auth backend run in this directory

    packer build -debug vault-image.json

If you don't want to push the Vault binary from your labtop due to bandwidth constraints, run instead to tell the VM to deal with the download itself

    packer build -debug vault-image-pull.json

The built image will have the following files ready to be used by a following up cloud-init based provisionning

* `/etc/vault/tls/ca.crt` Vault TLS Public Certificate
* `/etc/vault/config.hcl` Vault Agent configuration to grab the SSH CA file
* `/usr/local/bin/vault` Vault 1.3.0 binary

Packer have also added the following line to `/etc/ssh/sshd_config`

    TrustedUserCAKeys /etc/ssh/trusted-user-ca-keys.pem
 
# Provision a VM

Now that you have an image ready, you can switch over to the terraform directory to provision an instance from it.

    cd ../terraform

Configure all the required variables from the example file

    cp terraform.tfvars.example terraform.tfvars

Make sure you updated the image variable with the image ID from the Packer build.

Once everything is ready, launch the privisionning.

    terraform apply -auto-approve

You should now be able to sign your ssh public key and connect to this instance

    export VAULT_ADDR=https://<VAULT_API>
    export VAULT_NAMESPACE="<VAULT_NAMESPACE>"
    vault write -field=signed_key ssh/sign/<SSH_ROLE_NAME> public_key=@$HOME/.ssh/id_rsa.pub valid_principals=<USER> > ~/.ssh/id_rsa-cert.pub
    ssh <USER>@<IP_FROM_TERRAFORM_OUTPUT>

Congratulation, you now have an environment to automatically onboard your instances to your SSH Secret Engine living in your Vault namespace.