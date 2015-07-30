#!/bin/sh

LATEST=$(wget -q -O - https://s3.amazonaws.com/stellar.org/releases/stellar-core/latest)

export STELLAR_CORE_VERSION=$(echo "${LATEST}" | awk -Fstellar-core- '{print $2}' | awk -F_amd64 '{print $1}')

echo Packaging stellar-core version ${STELLAR_CORE_VERSION}

vagrant up

vagrant package --output stellar-core-base-${STELLAR_CORE_VERSION}.box
