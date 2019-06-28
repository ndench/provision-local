#!/bin/bash

set -eux

# Ask for sudo upfront
sudo -v

clone_path=~/git/ndench/provision-local

# Clone this repo
if [[ ! -d ${clone_path} ]]; then
  git clone https://github.com/ndench/provision-local.git ${clone_path}
fi

cd ${clone_path}

make

git remote set-url origin git@github.com:ndench/provision-local.git
