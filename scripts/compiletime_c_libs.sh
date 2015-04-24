#!/usr/bin/env bash

set -e

sudo apt-get -y purge clang clang-3.4
sudo apt-get -y autoremove
wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key | sudo apt-key add -
sudo apt-get update -qq
sudo apt-get install -qq python-software-properties
sudo add-apt-repository -y 'deb http://llvm.org/apt/trusty/ llvm-toolchain-trusty-3.5 main'
sudo add-apt-repository -y 'ppa:ubuntu-toolchain-r/test'
sudo apt-get update -qq
sudo apt-get install -qq autoconf automake libtool pkg-config flex bison clang-3.5 llvm-3.5 g++-4.9 libstdc++6 libpq5 libpq-dev
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 90 --slave /usr/bin/g++ g++ /usr/bin/g++-4.9
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-3.5 90 --slave /usr/bin/clang++ clang++ /usr/bin/clang++-3.5
sudo update-alternatives --install /usr/bin/llvm-symbolizer llvm-symbolizer /usr/bin/llvm-symbolizer-3.5 90
sudo rm -Rf /usr/local/clang*
hash -r
clang -v
g++ -v
