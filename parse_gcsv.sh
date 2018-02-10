#!/bin/bash
URL="https://docs.google.com/spreadshees/path/to/csv"
FILENAME="todaysharvest"
INFLUXDB_PORT="8086"
INFLUXDB_SERVER="localhost"
INFLUXDB_DATABASE="collectd"

wget "$URL" -O $FILENAME

{
read
while IFS='' read -r line || [[ -n "$line" ]]; do

  crop="$(echo "$line" | cut -d ',' -f 2 | tr -d '[:space:]')"
  harvest_date="$(echo "$line" | cut -d ',' -f 3| tr -d '[:space:]')"
  date="$(date -d $harvest_date +%s%N)"
  weight="$(echo "$line" | cut -d ',' -f 4 | tr -d '[:space:]')"
  piece="$(echo "$line" | cut -d ',' -f 5 | tr -d '[:space:]')"
  location="$(echo "$line" | cut -d ',' -f 6 | tr -d '[:space:]')"

  if [[ ! -z "${crop// }" ]]
    then 
    echo -n "$crop "
  else
    echo -n "none "
    crop="undefined_crop"
  fi

  if [[ ! -z "${weight// }" ]]
    then
    echo -n "$weight "
  else
    echo -n "none "
      weight="0"
  fi

  if [[ ! -z "${piece// }" ]]
    then
    echo -n "$piece "
  else
    echo -n "none "
    piece="0"
  fi

  if [[ ! -z "${location// }" ]]
    then
    echo -n "$location "
  else
    echo -n "none "
    location="none"
  fi

  if [[ ! -z "${date// }" ]]
    then 
    echo "$date"
  else
    echo "none"
    date="invalid"
  fi

  lower_ensured=$(echo "$crop,location=$location weight=$weight,pieces=$piece $date" | tr '[:upper:]' '[:lower:]' | tr '\n' ' ')
  curl -i -XPOST $(echo "http://$INFLUXDB_SERVER:$INFLUXDB_PORT/write?db=$INFLUXDB_DATABASE") --data-binary "${lower_ensured}"
  sleep 5

done
} < $FILENAME
