#!/bin/bash

set -eu

echo "Asking for sudo password upfront so that it's cached"
sudo -v

sudo pacman -S --noconfirm --needed git make

# Clone this repo
clone_path=~/git/ndench/provision-local
if [[ ! -d ${clone_path} ]]; then
  git clone https://github.com/ndench/provision-local.git ${clone_path}
fi

if [[ ! -f ${clone_path}/.ansible_vault.pass ]]; then
  read -sp "Enter vault password: " vault_password
  echo ${vault_password} > ${clone_path}/.ansible_vault.pass
fi

cd ${clone_path}
git pull

make install git-remote rcup
