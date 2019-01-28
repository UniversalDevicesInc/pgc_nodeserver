#!/bin/bash

[[ -z "$PGURL" ]] && { echo "PGURL environment variable not found. Exiting."; exit 1; }

curl -X GET $PGURL -o .env
cat .env
GITURL=`cat .env | jq '.nodeServer.url' | tr -d '"'`
MQTTURL=`cat .env | jq '.mqttUrl' | tr -d '"'`
[[ -z "$GITURL" ]] && { echo "GIT URL not found in config. Exiting."; exit 1; }
[[ -z "$MQTTURL" ]] && { echo "MQTT URL not found in config. Exiting."; exit 1; }
NODESERVER=`cat .env | jq '.nodeServer'`

if [ -z "$LOCAL" ]
then
  git clone --depth 1 $GITURL nodeserver
else
  ln -s /app/template/ nodeserver
  ln -s /app/pgc_interface nodeserver/pgc_interface
fi

cd /app/nodeserver
head -5 /app/nodeserver/pgc_interface/pgc_interface.py


CLOUDINSTALL=`cat server.json | jq '.install_cloud' | tr -d '"'`
[[ -z "$CLOUDINSTALL" ]] && { echo ".install_cloud not found in server.json. Exiting."; exit 1; }
TYPE=`cat server.json | jq '.type' | tr -d '"'`
[[ -z "$TYPE" ]] && { echo "type not found in server.json. Exiting."; exit 1; }
EXECUTABLE=`cat server.json | jq '.executable' | tr -d '"'`
[[ -z "$EXECUTABLE" ]] && { echo "executable not found in server.json. Exiting."; exit 1; }

# [[ $TYPE == "python" ]] && { /usr/bin/env pip install pgc_interface; }
if [ $TYPE == "python3" ]
then
  if [ -z "$LOCAL" ]
  then
    /usr/bin/env pip3 install 'pgc_interface>=1.1.0'
  fi
  # /usr/bin/env pip3 install paho-mqtt
fi
# [[ $TYPE == "node" ]] && { /usr/bin/env npm install pgc_interface; }

/usr/bin/env bash -xe ./$CLOUDINSTALL
PGURL=$PGURL MQTTURL=$MQTTURL NODESERVER=$NODESERVER /usr/bin/env $TYPE ./$EXECUTABLE
