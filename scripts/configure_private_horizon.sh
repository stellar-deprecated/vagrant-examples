#!/usr/bin/env bash

url=https://github.com/stellar/horizon/releases/download/pre-alpha1/horizon.jar
mkdir -p /opt/stellar/horizon/lib
curl -sfL "${url}" -o /opt/stellar/horizon/lib/horizon.jar

mkdir -p /opt/stellar/horizon/bin

cat > /opt/stellar/horizon/bin/start <<SH
#!/bin/sh

set -e

cd "\$(dirname "\$0")/.."

export DATABASE_URL="postgres://stellar"
export HAYASHI_DATABASE_URL="postgres://horizon:ENTER_PASSWORD_HERE@192.168.163.30:5432/stellar"
export STELLARD_URL="http://192.168.163.30:39132"
export FRIENDBOT_SECRET="deadbeef"
export RAILS_ENV=production
export IMPORT_HISTORY=true

java -jar lib/horizon.jar -b 0.0.0.0 -p 8001
SH
chmod +x /opt/stellar/horizon/bin/start

chown -R stellar:stellar /opt/stellar

sudo -iu stellar createdb stellar

# TODO: migrations should happen here, but I don't think we have a way to run them yet

cat > /etc/init/stellar-horizon.conf <<UPSTART
# THIS FILE IS DEPLOYED VIA PUPPET
start on runlevel [2345]
stop on runlevel [06]

setuid stellar
setgid stellar

# increase limits
limit nofile 8192 10240

respawn

chdir /opt/stellar/home

exec /opt/stellar/horizon/bin/start
UPSTART

start stellar-horizon
