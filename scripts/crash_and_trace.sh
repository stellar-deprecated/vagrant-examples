#!/usr/bin/env bash

set -e

stop stellar-core || true
sed -i.bak 's/^PEER_SEED=.*/PEER_SEED=""/' /opt/stellar/stellar-core/etc/stellar-core.cfg
start stellar-core

BIN=/opt/stellar/stellar-core/bin/stellar-core
CORE=/opt/stellar/home/core

until [[ -f "${CORE}" ]]; do
  sleep 0.5
done

exec lldb-3.6 -f "${BIN}" -c "${CORE}" --batch -o "target create -c ${CORE} ${BIN}" -o "thread backtrace all"
