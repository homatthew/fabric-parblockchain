#!/bin/bash

KEY=`ls ./crypto-config/peerOrganizations/org1.example.com/ca/ | grep "_sk"`

docker run -it --rm \
           --network="mynet" \
           --name ca.org1.example.com \
           -p 7054:7054 \
           -e TZ="Europe/Berlin" \
           -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=my-net \
           -e FABRIC_CA_HOME=/etc/hyperledger/fabric-ca-server \
           -e FABRIC_CA_SERVER_CA_CERTFILE=/etc/hyperledger/fabric-ca-server-config/ca.org1.example.com-cert.pem \
           -e FABRIC_CA_SERVER_CA_KEYFILE=/etc/hyperledger/fabric-ca-server-config/${KEY} \
           -e FABRIC_CA_SERVER_CA_NAME=ca.org1.example.com \
           -v $(pwd)/crypto-config/peerOrganizations/org1.example.com/ca/:/etc/hyperledger/fabric-ca-server-config \
           hyperledger/fabric-ca:1.2.0 \
           sh -c 'fabric-ca-server start -b admin:adminpw -d'
