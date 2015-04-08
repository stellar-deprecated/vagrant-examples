#!/usr/bin/env bash

set -e

apt-get install -y postgresql postgresql-contrib

cat >> /etc/postgresql/9.3/main/postgresql.conf <<CONF
listen_addresses = '*'
CONF

cat >> /etc/postgresql/9.3/main/pg_hba.conf <<CONF
host	all		all		all			md5
CONF

sudo -u postgres createuser -s stellar

horizon_password="ENTER_PASSWORD_HERE"

sudo -u postgres psql -c \
  "create role horizon with encrypted password '${horizon_password}'"
