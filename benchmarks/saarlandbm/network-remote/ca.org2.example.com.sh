#!/bin/bash

KEY=`ls crypto-config/peerOrganizations/org2.example.com/ca/ | grep "_sk"`

docker run --rm -it \
           --network="mynet" \
           --name ca.org2.example.com \
           -p 8054:7054 \
           -e TZ="Europe/Berlin" \
           -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=my-net \
           -e FABRIC_CA_HOME=/etc/hyperledger/fabric-ca-server \
           -e FABRIC_CA_SERVER_CA_CERTFILE=/etc/hyperledger/fabric-ca-server-config/ca.org2.example.com-cert.pem \
           -e FABRIC_CA_SERVER_CA_KEYFILE=/etc/hyperledger/fabric-ca-server-config/${KEY} \
           -e FABRIC_CA_SERVER_CA_NAME=ca.org2.example.com \
           -v $(pwd)/crypto-config/peerOrganizations/org2.example.com/ca/:/etc/hyperledger/fabric-ca-server-config \
           hyperledger/fabric-ca \
           sh -c 'fabric-ca-server start -b admin:adminpw -d'
