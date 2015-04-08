#!/usr/bin/env bash

set -e

apt-get install -y git
git clone https://github.com/stellar/stellar-core.git
cd stellar-core
./autogen.sh
./configure
make
