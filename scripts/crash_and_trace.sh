#!/usr/bin/env bash

set -e

stop stellar-core || true
sed -i.bak 's/^PEER_SEED=.*/PEER_SEED=""/' /opt/stellar/stellar-core/etc/stellar-core.cfg
start stellar-core

bin=/opt/stellar/stellar-core/bin/stellar-core
core=/opt/stellar/home/core

until [[ -f "${core}" ]]; do
  sleep 0.5
done

exec lldb-3.6 -f "${bin}" -c "${core}" \
  --batch \
  -o "target create -c '${core}' '${bin}'" \
  -o "script import time; time.sleep(1)" \
  -o "thread backtrace all" \
  2>&1
