#!/usr/bin/env bash

set -e

mkdir -p /opt/stellar/stellar-core/{bin,etc}

cp stellar-core/bin/stellar-core /opt/stellar/stellar-core/bin

chown -R stellar:stellar /opt/stellar

