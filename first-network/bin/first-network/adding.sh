#!/bin/bash
## adding to the defualts -- peer=2 org=3
echo "adding new organaization"

PEERN=$2
CURNTORG=0
CURNTPEER=0
ORGN=$1
echo " adding $ORGN"

field=()

for i in ${@:2}
do
	field+=("$i")

done
#for i in $ORGN
#do
#    echo " enter the num of peer in  org$i"
#    read -r input 
#    field+=("$input")
#    echo " the fld is ${field[$i]}"
#done
echo Num items: ${#field[@]}
echo Data: ${field[@]}

echo " adding $ORGN"


FORORG=$(($ORGN-$CURNTORG))
FORPEER=$(($PEERN))
###### adding in CryptoConfig file 
####  for adiing the organization that you chose 
#### to add with the number of the peers that you want
############ Template count = NUMOFPEERS
addingInCryptoConfig(){
truncate -s 0 first-network/crypto-config.yaml
echo "
OrdererOrgs:
  # ---------------------------------------------------------------------------
  # Orderer
  # ---------------------------------------------------------------------------
  - Name: Orderer
    Domain: example.com
    # ---------------------------------------------------------------------------
    # "Specs" - See PeerOrgs below for complete description
    # ---------------------------------------------------------------------------
    Specs:
      - Hostname: orderer
      - Hostname: orderer2
      - Hostname: orderer3
      - Hostname: orderer4
      - Hostname: orderer5
      - Hostname: orderer6
      - Hostname: orderer7" >> first-network/crypto-config.yaml
echo "
PeerOrgs:" >> first-network/crypto-config.yaml
for i in $(seq 0 $(($ORGN-1)))
do
	

	echo " # ---------------------------------------------------------------------------" 
	echo " # ---------------------------------------------------------------------------" >> first-network/crypto-config.yaml
	OURNUM=$(($i+1))
	echo "  # Org$OURNUM: See "Org1" for full specification " >> crypto-config.yaml
	echo "  # ---------------------------------------------------------------------------" >> first-network/crypto-config.yaml
	echo "  - Name: Org$OURNUM" >> first-network/crypto-config.yaml
	echo "    Domain: org$OURNUM.example.com" >> first-network/crypto-config.yaml
	echo "    EnableNodeOUs: true" >> first-network/crypto-config.yaml
	echo "    Template:" >> first-network/crypto-config.yaml
	echo "      Count: ${field[$i]}" >> first-network/crypto-config.yaml
	echo "    Users:" >> first-network/crypto-config.yaml
	echo "      Count: 2" >> first-network/crypto-config.yaml

done
}
##########################################
##### add the org to the cahnnel 
addingInConfigtx(){
truncate -s 0 first-network/configtx.yaml
CRNTPORT=11051
curnn=$CURNTORG
./first-network/change.sh $ORGN
}



##############################
### adding in docker compose cli file 
### adding the peers (dockers) to the volumes and services
changeInDockerComposeCli(){
truncate -s 0 first-network/docker-compose-cli.yaml
echo "
version: '2'

volumes:
  orderer.example.com:" >>first-network/docker-compose-cli.yaml
for i in $(seq 0 $(($ORGN-1)))
do
    for z in $(seq 0 $((${field[$i]}-1)))
    do
       PEER=$(($z))
       OR=$(($i+1))
       echo "  peer$PEER.org$OR.example.com:" >> first-network/docker-compose-cli.yaml
    done
done
echo "
networks:
  byfn:

services:

  orderer.example.com:
    extends:
      file:   base/docker-compose-base.yaml
      service: orderer.example.com
    container_name: orderer.example.com
    networks:
      - byfn">> first-network/docker-compose-cli.yaml
img='$IMAGE_TAG'
for i in $(seq 0 $(($ORGN-1)))
do
    for z in $(seq 0 $((${field[$i]}-1)))
    do
       PEER=$(($z))
       OR=$(($i+1))
       echo "
  peer$PEER.org$OR.example.com:
    container_name: peer$PEER.org$OR.example.com
    extends:
      file:  base/docker-compose-base.yaml
      service: peer$PEER.org$OR.example.com
    networks:
      - byfn" >> first-network/docker-compose-cli.yaml
    done
done
echo "
  cli:
    container_name: cli
    image: hyperledger/fabric-tools:$img
    tty: true
    stdin_open: true
    environment:
      - GOPATH=/opt/gopath
      - CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
      #- FABRIC_LOGGING_SPEC=DEBUG
      - FABRIC_LOGGING_SPEC=INFO
      - CORE_PEER_ID=cli
      - CORE_PEER_ADDRESS=peer0.org1.example.com:7051
      - CORE_PEER_LOCALMSPID=Org1MSP
      - CORE_PEER_TLS_ENABLED=true
      - CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
      - CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
      - CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
      - CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    working_dir: /opt/gopath/src/github.com/hyperledger/fabric/peer
    command: /bin/bash
    volumes:
        - /var/run/:/host/var/run/
        - ./../chaincode/:/opt/gopath/src/github.com/chaincode
        - ./crypto-config:/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/
        - ./scripts:/opt/gopath/src/github.com/hyperledger/fabric/peer/scripts/
        - ./channel-artifacts:/opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts
    depends_on:
      - orderer.example.com" >> first-network/docker-compose-cli.yaml

for i in $(seq 0 $(($ORGN-1)))
do
    for z in $(seq 0 $((${field[$i]}-1)))
    do
       PEER=$(($z))
       OR=$(($i+1))
       echo "      - peer$PEER.org$OR.example.com" >> first-network/docker-compose-cli.yaml
    done
done
echo "
    networks:
      - byfn" >> first-network/docker-compose-cli.yaml
}

####################################################
### upating the new peers to the couch database
### each peer have his own database
changeInDockerComposeCouch(){
truncate -s 0 first-network/docker-compose-couch.yaml
echo " 
version: '2'

networks:
  byfn:

services:" >> first-network/docker-compose-couch.yaml
couchdb=0
PORT=5984
for i in $(seq 0 $(($ORGN-1)))
do
    for z in $(seq 0 $((${field[$i]}-1)))
    do
       PEER=$(($z))
       OR=$(($i+1))
       echo "
  couchdb$couchdb:
    container_name: couchdb$couchdb
    image: hyperledger/fabric-couchdb
    # Populate the COUCHDB_USER and COUCHDB_PASSWORD to set an admin user and password
    # for CouchDB.  This will prevent CouchDB from operating in an "Admin Party" mode.
    environment:
      - COUCHDB_USER=
      - COUCHDB_PASSWORD=
    # Comment/Uncomment the port mapping if you want to hide/expose the CouchDB service,
    # for example map it to utilize Fauxton User Interface in dev environments.
    ports:
      - "$PORT:5984"
    networks:
      - byfn

  peer$PEER.org$OR.example.com:
    environment:
      - CORE_LEDGER_STATE_STATEDATABASE=CouchDB
      - CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS=couchdb$couchdb:5984
      # The CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME and CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD
      # provide the credentials for ledger to connect to CouchDB.  The username and password must
      # match the username and password set for the associated CouchDB.
      - CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME=
      - CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD=
    depends_on:
      - couchdb$couchdb">> first-network/docker-compose-couch.yaml
        couchdb=$(($couchdb+1))
        PORT=$(($PORT+1000))
    done
done

}

#########################################################
### updating the docker-compose file with the new peers
### each peer have a uniqe port and we add the peers to bootstrap peer
###
##########################################################


changeInBase(){
truncate -s 0 first-network/base/docker-compose-base.yaml
echo "
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

version: '2'

services:

  orderer.example.com:
    container_name: orderer.example.com
    extends:
      file: peer-base.yaml
      service: orderer-base
    volumes:
        - ../channel-artifacts/genesis.block:/var/hyperledger/orderer/orderer.genesis.block
        - ../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp:/var/hyperledger/orderer/msp
        - ../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/:/var/hyperledger/orderer/tls
        - orderer.example.com:/var/hyperledger/production/orderer
    ports:
      - 7050:7050" >> first-network/base/docker-compose-base.yaml

CURPORT=6051
CURPORTt=6051
###### adding the peers
FORNEWORG=$CURNTORG
FORNEWPEER=$(($PEERN-$CURNTPEER))

##########################################################
for m in $(seq 1 $ORGN )
do

	OURNUM=$m
        OURNUM1=$(($OURNUM-1))
	n=5
        PORTLa=$(($OURNUM1*$n))
	PORTLa=$(($PORTLa*1000))

        PEERMUL=1000*$(($PEERN-1))
	PORTLa=$(($PORTLa+$PEERMUL+7051))

	FOR=-1
	
			
		FOR=$(($FOR+1))
                ind=($(($m-1)))
		J=${field[$ind]}

			OURNUM=$m
			OURNUM1=$(($OURNUM-1))
			n=5
			PORTLa=$(($OURNUM1*$n))
			PORTLa=$(($PORTLa*1000))
	
			PEERMUL=1000*$(($J-1))
			PORTLa=$(($PORTLa+$PEERMUL+7051))
				

			PEERBOOT=0
                        
			for z in $(seq 0 $(($J-1)))
			do
				

				if [ $z = 0 ];then
				   First=$(($CURPORTt+1000))
				   PORTBOOT=$PORTLa
				   PEERBOOT=$(($J))	
				else
				   if [ $z = $J ];then
				  	 PORTBOOT=$First
					 OURNUM=$m
		       		         OURNUM1=$(($OURNUM-1))
					 PORTLa=$(($OURNUM1*$n))
					 PORTLa=$(($PORTLa*1000))
	
					 PEERMUL=0
					 PORTBOOT=$(($PORTLa+$PEERMUL+7051))
					 PEERBOOT=0
				else
				   PORTBOOT=$First
				   OURNUM=$m
		       		   OURNUM1=$(($OURNUM-1))
				   PORTLa=$(($OURNUM1*$n))
				   PORTLa=$(($PORTLa*1000))
	
				   PEERMUL=0
				   PORTBOOT=$(($PORTLa+$PEERMUL+7051))
				   PEERBOOT=0
				   fi
				fi
				PEER=$(($z))	
				MSP='Org'
				MSP1='MSP'
				n=5
				coMSP="$MSP$OURNUM$MSP1"
				OURNUM1=$(($OURNUM-1))
				PORT=$(($OURNUM1*$n))
				PORT=$(($PORT*1000))
				PORT=$(($PORT+$(($((1000*$(($PEER))))+7051))))
				echo "

  peer$PEER.org$OURNUM.example.com:
    container_name: peer$PEER.org$OURNUM.example.com
    extends:
      file: peer-base.yaml
      service: peer-base
    environment:
      - CORE_PEER_ID=peer$PEER.org$OURNUM.example.com
      - CORE_PEER_ADDRESS=peer$PEER.org$OURNUM.example.com:$PORT
      - CORE_PEER_LISTENADDRESS=0.0.0.0:$PORT
      - CORE_PEER_CHAINCODEADDRESS=peer$PEER.org$OURNUM.example.com:$(($PORT+1))
      - CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:$(($PORT+1))
      - CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer$PEER.org$OURNUM.example.com:$PORT
      - CORE_PEER_GOSSIP_BOOTSTRAP=peer$PEERBOOT.org$OURNUM.example.com:$PORTBOOT
      - CORE_PEER_LOCALMSPID=$coMSP
    volumes:
        - /var/run/:/host/var/run/
        - ../crypto-config/peerOrganizations/org$OURNUM.example.com/peers/peer$PEER.org$OURNUM.example.com/msp:/etc/hyperledger/fabric/msp
        - ../crypto-config/peerOrganizations/org$OURNUM.example.com/peers/peer$PEER.org$OURNUM.example.com/tls:/etc/hyperledger/fabric/tls
        - peer$PEER.org$OURNUM.example.com:/var/hyperledger/production
    ports:
      - $PORT:$PORT
  ">> first-network/base/docker-compose-base.yaml
				CURPORT=$PORT
				CURPORTt=$CURPORT
			done
		
	
	
done
}

###########################################
#### adding the CA for each organization 

changeInDockerCompose2e(){
truncate -s 0 first-network/docker-compose-e2e-template.yaml
PORT=7054
echo " 
version: '2'

volumes: 
  orderer.example.com:" >>first-network/docker-compose-e2e-template.yaml

for i in $(seq 0 $(($ORGN-1)))
do
    for z in $(seq 0 $((${field[$i]}-1)))
    do
       PEER=$(($z))
       OR=$(($i+1))
       echo "  peer$PEER.org$OR.example.com:" >> first-network/docker-compose-e2e-template.yaml
    done
done
echo "
networks:
  byfn:
services:" >> first-network/docker-compose-e2e-template.yaml
img='$IMAGE_TAG'
for i in $(seq 0 $(($ORGN-1)))
do
       OR=$(($i+1))
       x="CA$OR"
       y="_PRIVATE_KEY"
       z="$x$y"
       
       echo "
  ca$i:
    image: hyperledger/fabric-ca:$img
    environment:
      - FABRIC_CA_HOME=/etc/hyperledger/fabric-ca-server
      - FABRIC_CA_SERVER_CA_NAME=ca-org$OR
      - FABRIC_CA_SERVER_TLS_ENABLED=true
      - FABRIC_CA_SERVER_TLS_CERTFILE=/etc/hyperledger/fabric-ca-server-config/ca.org$OR.example.com-cert.pem
      - FABRIC_CA_SERVER_TLS_KEYFILE=/etc/hyperledger/fabric-ca-server-config/$z
    ports:
      - "$PORT:$PORT"
    command: sh -c 'fabric-ca-server start --ca.certfile /etc/hyperledger/fabric-ca-server-config/ca.org$OR.example.com-cert.pem --ca.keyfile /etc/hyperledger/fabric-ca-server-config/$z -b admin:adminpw -d'
    volumes:
      - ./crypto-config/peerOrganizations/org$OR.example.com/ca/:/etc/hyperledger/fabric-ca-server-config
    container_name: ca_peerOrg$OR
    networks:
      - byfn">> first-network/docker-compose-e2e-template.yaml
     PORT=$(($PORT+1000))
done

for i in $(seq 0 $(($ORGN-1)))
do
    for z in $(seq 0 $((${field[$i]}-1)))
    do
       PEER=$(($z))
       OR=$(($i+1))
	echo "
  peer$PEER.org$OR.example.com:
    container_name: peer$PEER.org$OR.example.com
    extends:
      file:  base/docker-compose-base.yaml
      service: peer$PEER.org$OR.example.com
    networks:
      - byfn">> first-network/docker-compose-e2e-template.yaml
    done
done


}
###################################
###### for taking the private key from the docker-compose-e2e
replacePrivateKey(){
truncate -s 0 first-network/byfn.sh
cp addbyfn.sh first-network/byfn.sh
# do in for
for m in $(seq 1 $ORGN )
do
	OURNUM=$(($m))
	sed -i '/# If MacOSX, remove the temporary backup of the docker-compose file/a \
  cd crypto-config/peerOrganizations/org'$OURNUM'.example.com/ca/ \
  PRIV_KEY=$(ls *_sk) \
  cd "$CURRENT_DIR" \
  sed $OPTS "s/CA'$OURNUM'_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose-e2e.yaml' first-network/byfn.sh
done

}

byfnchanges(){
for m in $(seq 1 $ORGN )
do
	OURNUM=$(($m))
sed -i '/#######    Generating anchor peer update for Org1MSP   ##########/a \
  set -x \
  configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org'$OURNUM'MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org'$OURNUM'MSP\
  res=$? \
  set +x \
  if [ $res -ne 0 ]; then \
    echo "Failed to generate anchor peer update for Org'$OURNUM'MSP..." \
    exit 1 \
  fi' first-network/byfn.sh
done

}

scriptschanges(){
truncate -s 0 first-network/scripts/utils.sh
cp first-network/scripts/addutils.sh scripts/utils.sh
for m in $(seq 1 $ORGN )
do 
	OURNUM=$(($m))
	sed -i '/# This is a collection of bash functions used by different scripts/a \
PEER0_ORG'$OURNUM'_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org'$OURNUM'.example.com/peers/peer0.org'$OURNUM'.example.com/tls/ca.crt' first-network/scripts/utils.sh
done

}



changeinutils(){
truncate -s 0 first-network/scripts/script.sh
cp first-network/scripts/addscript.sh scripts/script.sh

for m in $(seq 1 $ORGN )
do
	OURNUM=$(($m))
	sed -i '/echo "Install chaincode on peer0.org2..."/a \
installChaincode 0 '$OURNUM'' scripts/script.sh
done

for m in $(seq 1 $ORGN )
do
	OURNUM=$(($m))
	sed -i '/echo "Updating anchor peers for org1..."/a \
updateAnchorPeers 0 '$OURNUM'' first-network/scripts/script.sh
done

for z in $(seq 1 $ORGN )
do
	FOR=-1
        ind=$(($z-1))
        m=${field[$ind]}	
sed -i '/joinChannel () {/a \
	  for i in $(seq 1 '$m' ); do \
                peer=$(($i-1))\
		joinChannelWithRetry $peer '$z' \
		echo "===================== peer${peer}.org'$z' joined channel '\'$CHANNEL_NAME\'' ===================== " \
		sleep $DELAY \
		echo \
	  done \
' first-network/scripts/script.sh

done
}

changeinutils 
changeInBase 
changeInDockerCompose2e 
changeInDockerComposeCouch 
changeInDockerComposeCli 
addingInConfigtx 
addingInCryptoConfig 
#scriptschanges 
replacePrivateKey 
byfnchanges 

