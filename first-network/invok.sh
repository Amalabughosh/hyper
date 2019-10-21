#!/bin/bash
# Obtain the OS and Architecture string that will be used to select the correct
# native binaries for your platform, e.g., darwin-amd64 or linux-amd64
# timeout duration - the duration the CLI should wait for a response from
# another container before giving up
CLI_TIMEOUT=10
# default for delay between commands
CLI_DELAY=3
# channel name defaults to "mychannel"
CHANNEL_NAME=$4
text=$1
peer=$2
org=$3
#
# use golang as the default language for chaincode
LANGUAGE=golang
export VERBOSE=false

etext=`echo -n $text | base64`
docker exec cli scripts/innvoke.sh $CHANNEL_NAME $CLI_DELAY $LANGUAGE $CLI_TIMEOUT $VERBOSE $etext $peer $org

