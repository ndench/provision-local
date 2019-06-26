#!/bin/bash

set -eux

# Ask for sudo upfront
sudo -v

# Install ansible
sudo pacman -S ansible --needed --noconfirm

# Install ansible module to manage AUR dependencies
if [[ ! -f /usr/share/ansible/plugins/modules/aur.py ]]; then
  # Download the package from the AUR
  AUR_PACKAGE=ansible-aur-git
  pushd $(mktemp -d)
  wget https://aur.archlinux.org/cgit/aur.git/snapshot/${AUR_PACKAGE}.tar.gz
  tar -vxf ${AUR_PACKAGE}.tar.gz

  # Install the package
  pushd ${AUR_PACKAGE}
  makepkg -si --noconfirm

  # Go back to where we were
  cd ~2
fi

make install
