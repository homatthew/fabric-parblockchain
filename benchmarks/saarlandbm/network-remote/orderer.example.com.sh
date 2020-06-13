#!/bin/bash

: ${LOGGING_LEVEL:=info}

docker image rm hail05:5000/orderer:local
docker pull hail05:5000/orderer:local
docker run -it --rm \
           --network="mynet" \
           --name orderer.example.com \
           -p 7050:7050 \
           -e TZ="Europe/Berlin" \
           -e ORDERER_GENERAL_LOGLEVEL=${LOGGING_LEVEL} \
           -e ORDERER_GENERAL_LISTENPORT=7050 \
           -e ORDERER_GENERAL_TLS_ENABLED=false \
           -e ORDERER_GENERAL_GENESISMETHOD=file \
           -e ORDERER_GENERAL_LISTENADDRESS=0.0.0.0 \
           -e ORDERER_GENERAL_LOCALMSPID=OrdererMSP \
           -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=mynet \
           -e ORDERER_GENERAL_LOCALMSPDIR=/var/hyperledger/orderer/msp \
           -e ORDERER_GENERAL_GENESISFILE=/var/hyperledger/orderer/genesis.block \
           -v $(pwd)/channel-artifacts:/var/hyperledger/orderer \
           -v $(pwd)/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp:/var/hyperledger/orderer/msp \
           -w /opt/gopath/src/github.com/hyperledger/fabric \
           hail05:5000/orderer:local \
           orderer
