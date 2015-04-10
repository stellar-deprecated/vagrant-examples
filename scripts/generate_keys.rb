#!/usr/bin/env ruby

require 'json'
require 'pathname'

key_file = Pathname.new('/vagrant/keys.json')

if key_file.exist?
  puts "Skipping key generation since #{key_file} already exists"
  exit 0
end

core_network = JSON.parse(ENV['CORE_NETWORK'])

def make_keypair
  genseed_output = `/opt/stellar/stellar-core/bin/stellar-core --genseed`
  pairs = {}
  genseed_output.split("\n").each do |line|
    key, value = line.split(": ")
    pairs[key] = value
  end
  pairs
end

keys = {}
core_network.keys.each do |name|
  keys[name] = {
    peer: make_keypair,
    validation: make_keypair
  }
end

File.open(key_file, 'w') { |f| f.write(JSON.pretty_generate(keys)) }
