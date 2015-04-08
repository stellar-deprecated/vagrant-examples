#!/usr/bin/env bash

set -e

apt-get install -y git
ssh-keyscan -t rsa github.com > ~/.ssh/known_hosts
git clone git@github.com:stellar/stellar-core.git
cd stellar-core
./autogen.sh
./configure
make
