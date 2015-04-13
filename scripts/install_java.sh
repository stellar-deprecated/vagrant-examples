#!/usr/bin/env bash


apt-get install -y python-software-properties
add-apt-repository -y 'ppa:webupd8team/java'

apt-get update \
  -o Dir::Etc::sourcelist="sources.list.d/webupd8team-java-trusty.list" \
  -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"

echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true |\
  /usr/bin/debconf-set-selections

apt-get install -y oracle-java8-installer
