#!/bin/bash

set -e
set +x

if [ "$#" -ne 7 ]; then
  echo "Usage: $0 host user db port password file drop" >&2
  exit 1
fi

if [ ! -f "$6" ]; then
  echo "File $6 not found"
  exit 1
fi

HOST=$1
USER=$2
DB=$3
PORT=$4
PASSWORD=$5
FILE_NAME=$6

PSQL_ARGS="-X --set AUTOCOMMIT=off --set ON_ERROR_STOP=on --single-transaction"

if [ "$#" -eq 7 ]; then
  DROP=$7
fi

CONN_STR="postgresql://${USER}:${PASSWORD}@${HOST}:${PORT}/${DB}?sslmode=require"

psql $PSQL_ARGS "${CONN_STR}" << EOF
  TRUNCATE TABLE food_tmp_table;
EOF

# Load food tmp table from CSV file
LOAD_CMD="copy food_tmp_table (name, categories, origin, barcode, fluid, energy, sodium, protein, carb, fat, image, deleted, version) FROM STDIN WITH (FORMAT 'csv', DELIMITER E',', HEADER, ENCODING 'LATIN1');"
cat "${FILE_NAME}" | psql $PSQL_ARGS "${CONN_STR}" -c "${LOAD_CMD}"
ret=$?
if [ $ret -ne 0 ]; then
   echo "Error in CSV file"
   exit $?
fi

# Mark food with removed flag if DROP argument is equal to 1
if [ "${DROP}" -eq "1" ]; then
psql $PSQL_ARGS "${CONN_STR}" << EOF
  UPDATE food_product SET removed = TRUE, modified_date = current_timestamp, synchronized = TRUE WHERE user_uuid IS NULL;
EOF
fi

# Load food from tmp table
psql $PSQL_ARGS "${CONN_STR}" -f loadFood.sql
ret=$?
if [ $ret -ne 0 ]; then
   echo "Error loading food data to database"
   exit $?
fi

echo "Food loaded successfully"
exit 0
