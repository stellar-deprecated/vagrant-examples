#!/usr/bin/env bash

set -e

wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key | sudo apt-key add -
sudo apt-get update -qq
sudo apt-get install -qq python-software-properties
sudo add-apt-repository -y 'deb http://llvm.org/apt/trusty/ llvm-toolchain-trusty-3.6 main'
sudo add-apt-repository -y 'ppa:ubuntu-toolchain-r/test'
sudo apt-get update -qq
sudo apt-get install -qq libstdc++6 libpq5 lldb-3.6
