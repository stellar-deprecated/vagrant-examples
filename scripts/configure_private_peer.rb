#!/usr/bin/env ruby

require 'json'
require 'pathname'
require 'erb'
require 'fileutils'

keys = JSON.parse(Pathname.new('/vagrant/keys.json').read)
core_network = JSON.parse(ENV['CORE_NETWORK'])

node_name = ENV['NODE_NAME']
peer_seed = keys[node_name]["peer"]["Secret seed"]
validation_seed = keys[node_name]["validation"]["Secret seed"]
preferred_peers = core_network.values
quorum_set = keys.values.map { |set| set["peer"]["Public"] }

template = -> file, template {
  File.open(file, 'w') { |f| f.write(ERB.new(template, nil, '-').result) }
}

template['/opt/stellar/stellar-core/etc/stellar-core.cfg', <<CFG]
PEER_PORT=39133
RUN_STANDALONE=false
LOG_FILE_PATH="/var/log/stellar-core.log"

HTTP_PORT=39132
PUBLIC_HTTP_PORT=true

PEER_SEED=<%= peer_seed.inspect %>

VALIDATION_SEED=<%= validation_seed.inspect %>

TARGET_PEER_CONNECTIONS=20

MAX_PEER_CONNECTIONS=30

PREFERRED_PEERS=<%= preferred_peers.inspect %>

KNOWN_PEERS=[]

QUORUM_THRESHOLD=2
QUORUM_SET=<%= quorum_set.inspect %>

DATABASE="postgresql://dbname=stellar"

<% core_network.each do |name, ip| %>
[HISTORY.<%= name %>]
<% if name == node_name -%>
get="cp /opt/stellar/stellar-core/{0} {1}"
put="cp {0} /opt/stellar/stellar-core/{1}"
mkdir="mkdir -p /opt/stellar/stellar-core/{0}"
<% else -%>
get="curl -sf http://<%= ip %>:8000/{0} -o {1}"
<% end -%>
<% end -%>
CFG
FileUtils.chmod(0600, '/opt/stellar/stellar-core/etc/stellar-core.cfg')

template["/opt/stellar/stellar-core/bin/start", <<SH]
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
    OPTS="${OPTS} --newdb"
fi

# Allow core dumps
ulimit -c unlimited

# Use newhist if no history available
if ! test -d /opt/stellar/stellar-core/history; then
    OPTS="${OPTS} --newhist <%= node_name %>"
fi

exec "${APP}" ${OPTS} "$@"
SH
FileUtils.chmod(0755, '/opt/stellar/stellar-core/bin/start')

FileUtils.chown_R('stellar', 'stellar', '/opt/stellar')

FileUtils.cp('/scripts/resources/stellar-core.conf', '/etc/init/stellar-core.conf')
FileUtils.cp('/scripts/resources/stellar-history.conf', '/etc/init/stellar-history.conf')

system('start stellar-history')

# force SCP progress on the first two nodes
if core_network.keys[0..1].include?(node_name)
  system('sudo -iu stellar /opt/stellar/stellar-core/bin/start --forcescp')
end

system('start stellar-core')
