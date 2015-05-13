#!/usr/bin/env bash

set -e

wget -nv -O stellar-core.deb https://s3.amazonaws.com/stellar.org/releases/stellar-core/stellar-core-${STELLAR_CORE_VERSION}_amd64.deb

dpkg -i stellar-core.deb

mkdir -p /opt/stellar/stellar-core/{bin,etc}

cp /usr/local/bin/stellar-core /opt/stellar/stellar-core/bin

chown -R stellar:stellar /opt/stellar

