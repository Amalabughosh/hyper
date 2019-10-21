#!/bin/bash

echo
echo " ____    _____      _      ____    _____ "
echo "/ ___|  |_   _|    / \    |  _ \  |_   _|"
echo "\___ \    | |     / _ \   | |_) |   | |  "
echo " ___) |   | |    / ___ \  |  _ <    | |  "
echo "|____/    |_|   /_/   \_\ |_| \_\   |_|  "
echo
echo "Build your first network (BYFN) end-to-end test"
echo
CHANNEL_NAME="$1"
DELAY="$2"
LANGUAGE="$3"
TIMEOUT="$4"
VERBOSE="$5"
: ${CHANNEL_NAME:="mychannel"}
: ${DELAY:="3"}
: ${LANGUAGE:="golang"}
: ${TIMEOUT:="10"}
: ${VERBOSE:="false"}
LANGUAGE=`echo "$LANGUAGE" | tr [:upper:] [:lower:]`
COUNTER=1
MAX_RETRY=10

CC_SRC_PATH="github.com/chaincode/chaincode_example02/go/"
if [ "$LANGUAGE" = "node" ]; then
	CC_SRC_PATH="/opt/gopath/src/github.com/chaincode/chaincode_example02/node/"
fi

if [ "$LANGUAGE" = "java" ]; then
	CC_SRC_PATH="/opt/gopath/src/github.com/chaincode/chaincode_example02/java/"
fi

echo "Channel name : "$CHANNEL_NAME



# import utils
. scripts/utils.sh


createChannel() {
	setGlobals 0 1

	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
		peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx >&log.txt
		res=$?
                set +x
	else
				set -x
		peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
		res=$?
				set +x
	fi
	cat log.txt
	verifyResult $res "Channel creation failed"
	echo "===================== Channel '$CHANNEL_NAME' created ===================== "
	echo
}




joinChannel () {


}

## Create channel
echo "Creating channel..."
createChannel 

## Join all the peers to the channel
echo "Having all peers join the channel..."
joinChannel 
## Set the anchor peers for each org in the channel
echo "Updating anchor peers for org1..."

echo "Updating anchor peers for org2..."

echo "Updating anchor peers for org3..."

## Install chaincode on peer0.org1 and peer0.org2
echo "Installing chaincode on peer0.org1..."

echo "Install chaincode on peer0.org2..."



# Instantiate chaincode on peer0.org2
echo "Instantiating chaincode on peer0.org2..."
instantiateChaincode 0 2

# Query chaincode on peer0.org1
echo "Querying chaincode on peer0.org1..."
chaincodeQuery 0 1 hellob

# Invoke chaincode on peer0.org1 and peer0.org2
echo "Sending invoke transaction on peer0.org1 peer0.org2..."
etext=`echo -n "my cod is" | base64`
chaincodeInvoke 0 1 $etext
sleep 15
chaincodeInvoke 0 1 $etext
sleep 15
chaincodeQuery 0 1 "hellob\nhello"
#chaincodeInvoke 0 2 text
#chaincodeInvoke 0 3 text
#chaincodeInvoke 0 4 text

## Install chaincode on peer1.org2



# Query on chaincode on peer1.org2, check if the result is 90
echo "Querying chaincode on peer1.org2..."

# Query chaincode on peer0.org3, check if the result is 90
#echo "Querying chaincode on peer0.org3..."
#chaincodeQuery 0 3 hellobhello

# Invoke chaincode on peer0.org1, peer0.org2, and peer0.org3
#echo "Sending invoke transaction on peer0.org1 peer0.org2 peer0.org3..."
#chaincodeInvoke 0 1 0 2 0 3

# Query on chaincode on peer0.org3, peer0.org2, peer0.org1 check if the result is 80
# We query a peer in each organization, to ensure peers from all organizations are in sync
# and there is no state fork between organizations.

#echo "Querying chaincode on peer0.org3..."
#chaincodeQuery 0 3 80

#echo "Querying chaincode on peer0.org2..."
#chaincodeQuery 0 2 80

#echo "Querying chaincode on peer0.org1..."
#chaincodeQuery 0 1 80



echo
echo "========= All GOOD, BYFN execution completed =========== "
echo

echo
echo " _____   _   _   ____   "
echo "| ____| | \ | | |  _ \  "
echo "|  _|   |  \| | | | | | "
echo "| |___  | |\  | | |_| | "
echo "|_____| |_| \_| |____/  "
echo

