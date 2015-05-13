#!/usr/bin/env bash

set -e

rm -rf stellar-core

apt-get clean

dd if=/dev/zero of=/EMPTY bs=1M || true
rm -f /EMPTY

cat /dev/null > ~/.bash_history
history -c
