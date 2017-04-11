#!/bin/bash

set -e # fail fast
set -x

: ${credentials:?required}

echo Sanity testing ${service_plan_image:-${image:-PostgreSQL}} with $credentials

uri=$(echo $credentials | jq -r '.uri // ""')

: ${uri:?missing from binding credentials}

psql ${uri} -c 'DROP TABLE IF EXISTS sanitytest;'
psql ${uri} -c 'CREATE TABLE sanitytest(value text);'
psql ${uri} -c "INSERT INTO sanitytest VALUES ('storage-test');"
psql ${uri} -c 'SELECT value FROM sanitytest;' | grep 'storage-test' || {
  echo Could not store and retrieve value in cluster!
  exit 1
}
