#!/usr/bin/env bash

set -e

if dpkg-query -W libstdc++6 libpq5 lldb-3.6; then
  exit 0
fi

wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key | apt-key add -
apt-get update -qq
apt-get install -qq python-software-properties
add-apt-repository -y 'deb http://llvm.org/apt/trusty/ llvm-toolchain-trusty-3.6 main'
add-apt-repository -y 'ppa:ubuntu-toolchain-r/test'
apt-get update -qq
apt-get install -qq libstdc++6 libpq5 lldb-3.6
