#!/bin/sh

# a simple backup script to backup a whole couchdb server or a single db

me=`basename $0`

if [ -n "$1" ]
# Test whether command-line argument is present (non-empty).
then
  server=$1
  serverurl="http://${server}/"

  if [ -n "$2" ]
  # Test whether command-line argument is present (non-empty).
  then
    db=$2
    dburl="${serverurl}${db}/"

    if [ -n "$3" ]
    # Test whether command-line argument is present (non-empty).
    then
      doc=$3
      docurl="${dburl}${doc}?attachments=true"
      docname="$server/$db/$doc.json"

      curl --silent -H "Accept: application/json" -o "$docname" "$docurl"
      echo "got $db $doc"
    else
      mkdir -p "$server/$db"
      curl --silent -H "Accept: application/json" -o "$server/$db/_db.json" "$dburl"
      echo "${dburl}_all_docs"
      curl --silent -X GET "${dburl}_all_docs" | jsawk 'this.rows.forEach(function(row){out(row.id)}); return null' | tr '\n' '\0' | xargs -n1 -0 -P8 "./${me}" $server $db
      echo " FINISHED: $server $db"
    fi
  else
    curl --silent -X GET "${serverurl}_all_dbs" | jsawk 'return this[0] == "_" ? null : this' | jsawk -n 'out(this)' | xargs -n1 -P2 "./${me}" $server
    echo " ALL DONE: $server"
  fi
else
  echo "Usage './$me <server url> <optional dbname>'"
fi
