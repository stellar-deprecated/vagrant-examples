#!/usr/bin/env bash

set -e

cd /tmp
wget http://download.libsodium.org/libsodium/releases/libsodium-1.0.2.tar.gz
tar -zxf libsodium-1.0.2.tar.gz
rm libsodium-1.0.2.tar.gz

cd libsodium-1.0.2/
./configure
make
make install
cd ..
rm -rf libsodium-1.0.2

cd /usr/lib/
ln -s ../local/lib/libsodium.so
