#!/bin/bash

set -e # fail fast

if [[ ${credentials:-x} == "x" ]]; then
  echo "No \$credentials provided, entering self-test mode."
  if [[ -f /.firstrun ]]; then
    echo Still starting PostgreSQL, waiting...
    sleep 5
  fi
  credentials=$(cat /config/credentials.json)
fi

echo Sanity testing ${service_plan_image:-${image:-PostgreSQL}} with $credentials

uri=$(echo $credentials | jq -r '.uri // .credentials.uri // ""')

: ${uri:?missing from binding credentials}

username=$( echo "$uri" | sed 's|[[:blank:]]*postgres://\([^:]\+\):\([^@]\+\)@\([^:]\+\):\([^/]\+\)\/\(.*\)[[:blank:]]*|\1|' )
password=$( echo "$uri" | sed 's|[[:blank:]]*postgres://\([^:]\+\):\([^@]\+\)@\([^:]\+\):\([^/]\+\)\/\(.*\)[[:blank:]]*|\2|' )
host=$(     echo "$uri" | sed 's|[[:blank:]]*postgres://\([^:]\+\):\([^@]\+\)@\([^:]\+\):\([^/]\+\)\/\(.*\)[[:blank:]]*|\3|' )
port=$(     echo "$uri" | sed 's|[[:blank:]]*postgres://\([^:]\+\):\([^@]\+\)@\([^:]\+\):\([^/]\+\)\/\(.*\)[[:blank:]]*|\4|' )
dbname=$(   echo "$uri" | sed 's|[[:blank:]]*postgres://\([^:]\+\):\([^@]\+\)@\([^:]\+\):\([^/]\+\)\/\(.*\)[[:blank:]]*|\5|' )

wait=${wait_til_running:-60}
echo "Waiting for $uri to be ready (max ${wait}s)"
for ((n=0; n<$wait; n++)); do
  pg_isready -h $host -p $port -d $dbname
  if [[ $? == 0 ]]; then
    echo "Postgres is ready"
    break
  fi
  print .
  sleep 1
done
pg_isready -h $host -p $port -d $dbname
if [[ $? != 0 ]]; then
  echo "Postgres not running"
  exit 1
fi

wait=${wait_til_running:-60}
echo "Waiting for $uri database to exist (max ${wait}s)"
for ((n=0; n<$wait; n++)); do
  psql ${uri} -c 'DROP TABLE IF EXISTS sanitytest;'
  if [[ $? == 0 ]]; then
    echo "Database is ready"
    break
  fi
  print .
  sleep 1
done
psql ${uri} -c 'DROP TABLE IF EXISTS sanitytest;'
if [[ $? != 0 ]]; then
  echo "Database not running"
  exit 1
fi

set -x
psql ${uri} -c 'CREATE TABLE sanitytest(value text);'
psql ${uri} -c "INSERT INTO sanitytest VALUES ('storage-test');"
psql ${uri} -c 'SELECT value FROM sanitytest;' | grep 'storage-test' || {
  echo Could not store and retrieve value in cluster!
  exit 1
}
