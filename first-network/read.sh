#!/bin/bash


CLI_TIMEOUT=10
# default for delay between commands
CLI_DELAY=3
# channel name defaults to "mychannel"
CHANNEL_NAME="$3"
peer=$1
org=$2
#
# use golang as the default language for chaincode
LANGUAGE=golang
export VERBOSE=false

docker exec cli scripts/query.sh $CHANNEL_NAME $CLI_DELAY $LANGUAGE $CLI_TIMEOUT $VERBOSE $peer $org
