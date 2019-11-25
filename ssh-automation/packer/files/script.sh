#!/bin/sh
sudo su <<HERE
apt-get install unzip
curl https://releases.hashicorp.com/vault/1.3.0/vault_1.3.0_linux_amd64.zip --output /usr/local/bin/vault.zip
unzip /usr/local/bin/vault.zip -d /usr/local/bin/
mkdir -p /etc/vault/tls
mv /tmp/ca.crt /etc/vault/tls/
mv /tmp/config.hcl /etc/vault
/bin/sh -c 'echo "TrustedUserCAKeys /etc/ssh/trusted-user-ca-keys.pem" >> /etc/ssh/sshd_config'
HERE