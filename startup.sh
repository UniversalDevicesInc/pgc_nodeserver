#!/bin/bash

if [ -z "$PGURL" ] || [ "$PGURL" == "null" ]
then
  echo "PGURL environment variable not found. Exiting."
  exit 1
fi

curl -X GET $PGURL -o .env
# cat .env
curl -X GET https://www.amazontrust.com/repository/AmazonRootCA1.pem -o /app/certs/AmazonRootCA1.pem
GITURL=`cat .env | jq '.nodeServer.url' | tr -d '"'`
MQTTENDPOINT=`cat .env | jq '.iotHost' | tr -d '"'`
STAGE=`cat .env | jq '.stage' | tr -d '"'`
cat .env | jq '.iotPrivateKey' | tr -d '"' | sed 's/\\n/\n/g' > /app/certs/private.key
cat .env | jq '.iotCert' | tr -d '"' | sed 's/\\n/\n/g' > /app/certs/iot.crt
[[ "$GITURL" == "null" ]] && { echo "GIT URL not found in config. Exiting."; exit 1; }
NODESERVER=`cat .env | jq '.nodeServer'`

if [ -z "$LOCAL" ] || [ "$LOCAL" == false ]
then
  git clone --depth 1 $GITURL nodeserver
else
  ln -s /app/template/ nodeserver
fi

if [ ! -z "$PGCLOCAL" ]
then
  ln -s /app/pgc_interface nodeserver/pgc_interface
  head -5 /app/nodeserver/pgc_interface/pgc_interface.py
fi

mkdir -p /app/logs.json
mkdir -p /app/certs
cd /app/nodeserver

TYPE=`cat server.json | jq '.type' | tr -d '"'`
[[ "$TYPE" == "null" ]] && { echo "type not found in server.json. Exiting."; exit 1; }
EXECUTABLE=`cat server.json | jq '.executable' | tr -d '"'`
[[ "$EXECUTABLE" == "null" ]] && { echo "executable not found in server.json. Exiting."; exit 1; }

# [[ $TYPE == "python" ]] && { /usr/bin/env pip install pgc_interface; }
if [ $TYPE == "python3" ]
then
  if [ -z "$PGCLOCAL" ] || [ "$PGCLOCAL" == false ]
  then
    /usr/bin/env pip3 install 'pgc_interface>=1.1.0'
  else
    /usr/bin/env pip3 install AWSIoTPythonSDK
  fi
fi
if [ $TYPE == "node" ]
then
  /usr/bin/env npm install
fi

CLOUDINSTALL=`cat server.json | jq '.install_cloud' | tr -d '"'`
if [ "$CLOUDINSTALL" == "null" ]
then
  echo "install_cloud not found in server.json. Skipping."
else
  /usr/bin/env bash -xe ./$CLOUDINSTALL
fi
STAGE=$STAGE MQTTENDPOINT=$MQTTENDPOINT NODESERVER=$NODESERVER /usr/bin/env $TYPE ./$EXECUTABLE
