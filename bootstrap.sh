#!/bin/bash

set -eux

# Ask for sudo upfront
sudo -v


# Clone this repo
if [[ ! -f ~/git/ndench/provision-local ]]; then
  git clone https://github.com/ndench/provision-local.git ~/git/ndench/provision-local
fi

cd ~/git/ndench/provision-local

make

# TODO: Uncomment this once github ssh keys are being added
#git remote set-url origin git@github.com:ndench/provision-local.git
