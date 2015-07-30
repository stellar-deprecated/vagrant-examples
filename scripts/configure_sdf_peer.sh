#!/usr/bin/env bash

set -e

mkdir -p /opt/stellar/stellar-core/{bin,etc}

cp stellar-core/bin/stellar-core /opt/stellar/stellar-core/bin

peer_pair=`/opt/stellar/stellar-core/bin/stellar-core --genseed`
peer_seed=`echo "${peer_pair}" | grep Secret | cut -d: -f2 | cut -b2-`

validation_pair=`/opt/stellar/stellar-core/bin/stellar-core --genseed`
validation_seed=`echo "${validation_pair}" | grep Secret | cut -d: -f2 | cut -b2-`

cat > /opt/stellar/stellar-core/etc/stellar-core.cfg <<CFG
PEER_PORT=39133
RUN_STANDALONE=false
LOG_FILE_PATH="/var/log/stellar-core.log"

HTTP_PORT=39132
PUBLIC_HTTP_PORT=false

DATABASE="postgresql://dbname=stellar"

PEER_SEED="${peer_seed}"

VALIDATION_SEED="${validation_seed}"

KNOWN_PEERS=[
  "core-testnet1.stellar.org",
  "core-testnet2.stellar.org",
  "core-testnet3.stellar.org"
]

[QUORUM_SET]
THRESHOLD=2
VALIDATORS=[
  "GDKXE2OZMJIPOSLNA6N6F2BVCI3O777I2OOC4BV7VOYUEHYX7RTRYA7Y",
  "GCUCJTIYXSOXKBSNFGNFWW5MUQ54HKRPGJUTQFJ5RQXZXNOLNXYDHRAP",
  "GC2V2EFSXN6SQTWVYA5EPJPBWWIMSD2XQNKUOHGEKB535AQE2I6IXV2Z"
]

[HISTORY.vagrant_single]
get="cp /opt/stellar/stellar-core/{0} {1}"
put="cp {0} /opt/stellar/stellar-core/{1}"
mkdir="mkdir -p /opt/stellar/stellar-core/{0}"

[HISTORY.core_testnet1]
get="curl -sf https://s3-eu-west-1.amazonaws.com/history.stellar.org/prd/core-testnet/core-testnet-001/{0} -o {1}"

[HISTORY.core_testnet2]
get="curl -sf https://s3-eu-west-1.amazonaws.com/history.stellar.org/prd/core-testnet/core-testnet-002/{0} -o {1}"

[HISTORY.core_testnet3]
get="curl -sf https://s3-eu-west-1.amazonaws.com/history.stellar.org/prd/core-testnet/core-testnet-003/{0} -o {1}"
CFG
chmod 600 /opt/stellar/stellar-core/etc/stellar-core.cfg

cat > /opt/stellar/stellar-core/bin/start <<CFG
#!/usr/bin/env bash

set -e

APP="/opt/stellar/stellar-core/bin/stellar-core"
OPTS="--conf /opt/stellar/stellar-core/etc/stellar-core.cfg"

# Initialze db if none found
if ! psql -c 'select 1' stellar >/dev/null 2>&1; then
    echo "Initializing database..."
    createdb -O stellar stellar

    psql >/dev/null <<SQL
GRANT CONNECT ON DATABASE stellar to horizon;
\\c stellar
REVOKE ALL ON schema public FROM public;
GRANT ALL ON schema public TO stellar;
GRANT USAGE ON SCHEMA public to horizon;

GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO horizon;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO horizon;

ALTER DEFAULT PRIVILEGES FOR USER stellar IN SCHEMA public GRANT SELECT ON SEQUENCES TO horizon;
ALTER DEFAULT PRIVILEGES FOR USER stellar IN SCHEMA public GRANT SELECT ON TABLES TO horizon;
SQL
    OPTS="\${OPTS} --newdb"
fi

# Allow core dumps
ulimit -c unlimited

# Use newhist if no history available
if ! test -d /opt/stellar/stellar-core/history; then
    OPTS="\${OPTS} --newhist vagrant_single"
fi

exec "\${APP}" \${OPTS} "\$@"
CFG

chmod +x /opt/stellar/stellar-core/bin/start

chown -R stellar:stellar /opt/stellar

touch /var/log/stellar-core.log
chown stellar:stellar /var/log/stellar-core.log

cat > /etc/init/stellar-core.conf <<UPSTART
# THIS FILE IS DEPLOYED VIA PUPPET
start on runlevel [2345]
stop on runlevel [06]

setuid stellar
setgid stellar

limit nofile 8192 10240

respawn

chdir /opt/stellar/home

exec /opt/stellar/stellar-core/bin/start
UPSTART

start stellar-core
