#!/bin/bash

set -eux

echo "Asking for sudo password upfront so that it's cached"
sudo -v

# Clone this repo
clone_path=~/git/ndench/provision-local
if [[ ! -d ${clone_path} ]]; then
  git clone https://github.com/ndench/provision-local.git ${clone_path}
  read -sp "Enter vault password: " vault_password
  echo ${vault_password} > ${clone_path}/.ansible_vault.pass
fi

cd ${clone_path}

make

git remote set-url origin git@github.com:ndench/provision-local.git
