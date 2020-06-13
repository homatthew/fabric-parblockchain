#!/bin/bash

: ${LOGGING_LEVEL:=info}

docker image rm hail05:5000/peer:local &>/dev/null

docker run -it \
           --network="mynet" \
           --name peer1.org1.example.com \
           -p 7051:7051 \
           -p 7053:7053 \
           -e TZ="Europe/Berlin" \
           -e CORE_LEDGER_STATE_STATEDATABASE=leveldb \
           -e CORE_LOGGING_LEVEL=${LOGGING_LEVEL} \
           -e CORE_NEXT=true \
           -e CORE_PEER_ADDRESSAUTODETECT=true \
           -e CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer.example.com:7050 \
           -e CORE_PEER_ENDORSER_ENABLED=true \
	         -e CORE_PEER_GOSSIP_BOOTSTRAP=peer0.org1.example.com:7051 \
           -e CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer1.org1.example.com:7051 \
           -e CORE_PEER_GOSSIP_IGNORESECURITY=true \
           -e CORE_PEER_GOSSIP_ORGLEADER=true \
           -e CORE_PEER_GOSSIP_USELEADERELECTION=false \
           -e CORE_PEER_ID=peer1.org1.example.com \
           -e CORE_PEER_LOCALMSPID=Org1MSP \
           -e CORE_PEER_NETWORKID=peer1.org1.example.com \
           -e CORE_PEER_PROFILE_ENABLED=false \
           -e CORE_PEER_TLS_ENABLED=false \
           -e CORE_CHAINCODE_DEPLOYTIMEOUT=300s \
           -e CORE_CHAINCODE_STARTUPTIMEOUT=300s \
           -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=mynet \
           -e CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock \
           -v /var/run/:/host/var/run/ \
           -v $(pwd)/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/msp:/etc/hyperledger/fabric/msp \
           -w /opt/gopath/src/github.com/hyperledger/fabric/peer \
           hail05:5000/peer:local \
           peer node start 2>&1 \
    | tee /var/nfs/logs/peer1-org1.log
