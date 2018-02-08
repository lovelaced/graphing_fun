#!/bin/bash
url="spreadsheet URL goes here"
wget "$url" -O todaysharvest

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

  lower_ensured=$(echo "$crop,location=$location weight=$weight,pieces=$piece $date" | tr '[:upper:]' '[:lower:]')
  echo $lower_ensured
  curl -i -XPOST 'http://localhost:8086/write?db=collectd' --data-binary "$lower_ensured"
  sleep 5

done
} < "todaysharvest"
