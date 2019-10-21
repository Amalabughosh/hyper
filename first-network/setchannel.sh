#!/bin/bash

echo "adding new channels"

CHANNEL=$1


field=()

for i in ${@:2:$1}
do
	field+=("$i")

done

echo Num items: ${#field[@]}
echo Data: ${field[@]}
ch=$(($1+2))
PEERS=${@:$ch}
echo " peers $PEERS"
echo " adding $CHANNEL"

PEERARR=()
word='' 
w=`echo "$PEERS" | fold -w1`
for c in $w
do

  if [ $c == ',' ]; then
	 PEERARR+=("$word")
         word=''     

  else 
      word+=$c
  fi
done
echo Data: ${PEERARR[@]}
echo Num items: ${#PEERARR[@]}


addingInConfigtx(){

word=''     
for i in $(seq 0 $(($CHANNEL-1)))
do 
       nmchnl=$(($i+1))
       chnl=()
       for a in ${field[$i]}
       do
          w=`echo "$a" | fold -w1`
	  for c in $w
	  do

		  if [ $c == ',' ]; then
	       		 chnl+=("$word")
		         word=''     

		  else 
		      word+=$c
		  fi
	  done

       done
       echo Data: ${chnl[@]}
       echo Num items: ${#chnl[@]}
       	sed -i '/#add new channels/a \
\
    Channel'$nmchnl':\
        Consortium: SampleConsortium\
        <<: *ChannelDefaults\
        Application:\
            <<: *ApplicationDefaults\
            Organizations: ############'$nmchnl'\
            Capabilities:\
                <<: *ApplicationCapabilities' configtx.yaml
       for j in $(seq 0 $((${#chnl[@]} - 1)))
       do
      	sed -i '/Organizations: ############'$nmchnl'/a \
                - *Org'${chnl[$j]}'  ' configtx.yaml
        


   done 


done

}
       
addingbyfn(){
for i in $(seq 0 $(($CHANNEL-1)))
do 
  nmchnl=$(($i+1))
  sed -i '/##channel configuration transaction/a \
   configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel'$nmchnl'.tx -channelID "channel'$nmchnl'" ' byfn.sh


  sed -i '/  # now run the end to end script/a \
  docker exec cli scripts/script.sh "channel'$nmchnl'" $CLI_DELAY $LANGUAGE $CLI_TIMEOUT $VERBOSE \
  sleep 6' byfn.sh
       chnl=()
       for a in ${field[$i]}
       do
          w=`echo "$a" | fold -w1`
	  for c in $w
	  do

		  if [ $c == ',' ]; then
	       		 chnl+=("$word")
		         word=''     

		  else 
		      word+=$c
		  fi
	  done

       done

       echo Data: ${chnl[@]}
       echo Num items: ${#chnl[@]}
       for j in $(seq 1 $((${#chnl[@]})))
       do
         m=$(($j-1))
         org=${chnl[$m]}
          echo Data: ${chnl[$m]}
         sed -i '/#######    Generating anchor peer update for Org1MSP   ##########/a \
  set -x \
  configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org'${chnl[$m]}'MSPanchorschannel'$nmchnl'.tx -channelID "channel'$nmchnl'" -asOrg Org'${chnl[$m]}'MSP\
  res=$? \
  set +x \
  if [ $res -ne 0 ]; then \
    echo "Failed to generate anchor peer update for Org'$OURNUM'MSP..." \
    exit 1  \
  fi ' byfn.sh

       done
done


}


addingscript(){

for i in $(seq 0 $(($CHANNEL-1)))
do 
         nmchnl=$(($i+1))
	 sed -i '/## Join all the peers to the channel/a \
if [ \$CHANNEL_NAME == \"channel'$nmchnl'\" ]; then\
     joinChannel'$nmchnl' \
fi' scripts/script.sh 




	sed -i '/###joinChannels/a \
joinChannel'$nmchnl'(){ \
##setGlobals'$nmchnl' \
createChannel \
## JOIN'$nmchnl' \
## UPDATE'$nmchnl' \
## INSTALL'$nmchnl' \
} \
' scripts/script.sh
############################################
	word=''     
	chnl=()
	for a in ${field[$i]}
	do
	  w=`echo "$a" | fold -w1`
	  for c in $w
	  do

		  if [ $c == ',' ]; then
	       		 chnl+=("$word")
			 word=''     

		  else 
		      word+=$c
		  fi
	  done

	done
###########################################
	for z in $(seq 1 ${#chnl[@]} )
	do
          L=$(($z-1))
	  m=${PEERARR[$((${chnl[$L]}-1))]}
          echo " num of peer${chnl[$L]}: $m"
          sed -i '/## JOIN'$nmchnl'/a \
    for i in $(seq 1 '$m' ); do \
	peer=$(($i-1)) \
	joinChannelWithRetry $peer '${chnl[$L]}' \
	echo "===================== peer${peer}.org'${chnl[$L]}' joined channel channel'$nmchnl'  ===================== " \
	sleep $DELAY \
	echo \
    done \
	' scripts/script.sh

       done

	for z in $(seq 1 ${#chnl[@]} )
	do
          L=$(($z-1))
          sed -i '/## UPDATE'$nmchnl'/a \
updateAnchorPeers 0 '${chnl[$L]}' ' scripts/script.sh
       done


          sed -i '/## INSTALL'$nmchnl' /a \
instantiateChaincode 0 '${chnl[0]}' ' scripts/script.sh

          sed -i '/##setGlobals'$nmchnl' /a \
setGlobals 0 '${chnl[0]}' ' scripts/script.sh

done

}
addingscript
addingbyfn
addingInConfigtx
