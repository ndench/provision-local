#!/bin/bash

set -eux

# Ask for sudo upfront
sudo -v


# Clone this repo
if [[ ! -f ~/git/ndench/provision-local ]]; then
  git clone https://github.com/ndench/provision-local.git ~/git/ndench/provision-local
  cd ~/git/ndench/provision-local
  git remote set-url origin git@github.com:ndench/provision-local.git
fi

cd ~/git/ndench/provision-local

source install-arch.sh
