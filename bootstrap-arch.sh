#!/bin/bash -eux

# Ask for sudo upfront
sudo -v

# Install ansible
sudo pacman -S ansible

# Install ansible module to manage AUR dependencies
AUR_PACKAGE=ansible-aur-git
cd $(mktemp -d)
wget https://aur.archlinux.org/cgit/aur.git/snapshot/${AUR_PACKAGE}.tar.gz
tar -vxf ${AUR_PACKAGE}.tar.gz
cd ${AUR_PACKAGE}
makepkg -si --noconfirm

# Run provisioning
git clone https://github.com/ndench/provision-local.git ~/git/ndench/provision-local

cd ~/git/ndench/provision-local
git remote set-url origin git@github.com:ndench/provision-local.git
