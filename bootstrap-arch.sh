#!/bin/sh

# Ask for sudo upfront
sudo -v

git clone https://github.com/ndench/provision-local.git ~/git/ndench/provision-local

cd ~/git/ndench/provision-local
git remote set-url origin git@github.com:ndench/provision-local.git

sudo pacman -S ansible
