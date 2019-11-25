#!/bin/bash

# configuring Vault Namespace
sudo sed -i 's/namespace = ""/namespace = "${vault_namespace}"/g' /etc/vault/config.hcl
sudo /usr/local/bin/vault agent -config=/etc/vault/config.hcl