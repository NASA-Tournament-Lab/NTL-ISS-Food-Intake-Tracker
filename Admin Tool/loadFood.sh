#!/bin/sh

if [ "$#" -ne 5 ]; then
  echo "Usage: $0 host user db port FILE" >&2
  exit 1
fi

if [ ! -f "$5" ]
  then
    echo "File $5 not found"
    exit 1
fi

HOST=$1
USER=$2
DB=$3
PORT=$4
FILE_NAME=$5

LOAD_CMD="copy food_tmp_table (name, categories, origin, barcode, fluid, energy, sodium, protein, carb, fat, image, deleted, version) FROM STDIN WITH (FORMAT 'csv', DELIMITER E',', HEADER);"

cat "${FILE_NAME}" | psql -h $HOST -U $USER -p $PORT $DB -w -c "${LOAD_CMD}" > /dev/null
ret=$?
if [ $ret -ne 0 ]; then
   echo "Error in CSV file"
   exit $?
fi

psql -h $HOST -U $USER -p $PORT $DB -w -f loadFood.sql > /dev/null 2> /dev/null
if [ $ret -ne 0 ]; then
   echo "Error update database"
   exit $?
fi

echo "Food loaded successfully"
exit 0
