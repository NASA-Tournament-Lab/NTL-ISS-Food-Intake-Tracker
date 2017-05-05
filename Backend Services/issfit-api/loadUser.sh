#!/bin/bash

set -e
set +x

if [ "$#" -ne 6 ]; then
  echo "Usage: $0 host user db port password file" >&2
  exit 1
fi

if [ ! -f "$6" ]
  then
    echo "File $6 not found"
    exit 1
fi

PSQL_ARGS="-X --set AUTOCOMMIT=off --set ON_ERROR_STOP=on --single-transaction"

HOST=$1
USER=$2
DB=$3
PORT=$4
PASSWORD=$5
FILE_NAME=$6

CONN_STR="postgresql://${USER}:${PASSWORD}@${HOST}:${PORT}/${DB}?sslmode=require"

# Load user CSV file
LOAD_CMD="copy user_tmp_table (full_name, admin, fluid, energy, sodium, protein, carb, fat, packets_per_day, profile_image, use_last_filter, weight) FROM STDIN WITH (FORMAT 'csv', DELIMITER E',', HEADER, ENCODING 'LATIN1');"
cat "${FILE_NAME}" | psql $PSQL_ARGS "${CONN_STR}" -w -c "${LOAD_CMD}"
ret=$?
if [ $ret -ne 0 ]; then
   echo "Error in CSV file"
   exit $?
fi

# Load user from tmp table
psql $PSQL_ARGS "${CONN_STR}" -f loadUser.sql
ret=$?
if [ $ret -ne 0 ]; then
   echo "Error update database"
   exit $?
fi

echo "User loaded successfully"
exit 0
