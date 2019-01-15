#!/bin/bash

[[ -z "$PGURL" ]] && { echo "PGURL environment variable not found. Exiting."; exit 1; }
curl -X GET $PGURL -o .env

GITURL=`cat .env | jq '.nodeServer.url' | tr -d '"'`
[[ -z "$GITURL" ]] && { echo "GIT URL not found in config. Exiting."; exit 1; }

git clone --depth 1 $GITURL nodeserver
cd "${0%/*}"/nodeserver

CLOUDINSTALL=`cat server.json | jq '.install_cloud' | tr -d '"'`
[[ -z "$CLOUDINSTALL" ]] && { echo ".install_cloud not found in server.json. Exiting."; exit 1; }
TYPE=`cat server.json | jq '.type' | tr -d '"'`
[[ -z "$TYPE" ]] && { echo "type not found in server.json. Exiting."; exit 1; }
EXECUTABLE=`cat server.json | jq '.executable' | tr -d '"'`
[[ -z "$EXECUTABLE" ]] && { echo "executable not found in server.json. Exiting."; exit 1; }

[[ $TYPE == "python" ]] && { /usr/bin/env pip install pgc_interface; }
[[ $TYPE == "python3" ]] && { /usr/bin/env pip3 install pgc_interface; }
# [[ $TYPE == "node" ]] && { /usr/bin/env npm install; }

/usr/bin/env bash -xe ./$CLOUDINSTALL
/usr/bin/env $TYPE ./$EXECUTABLE
