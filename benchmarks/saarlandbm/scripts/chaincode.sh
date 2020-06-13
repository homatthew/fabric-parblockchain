#!/bin/bash

USAGE="\
usage: $0 [local|remote]
"

### Main ###
if [ $# -ne 1 ];
then
	>&2 echo ${USAGE};
	exit 1;
fi

NETWORK=

case "$1" in
	"local")
		NETWORK=networklocal_mynet;
    cd network-local;
	  ;;
	"remote")
		NETWORK=mynet;
    cd network-remote;
		;;
	*)
		>&2 echo ${USAGE};
		exit 1;
		;;
esac

: ${INSTANTIATION_PEER:=0}
: ${CHANNEL_NAME:=mychannel}
: ${CHAINCODE_NAME:=mycc}
: ${CHAINCODE:=custom}
: ${NACCOUNTS:=10000}
: ${MONEY:=100000}
: ${PEER:=0}
: ${ORG:=1}

docker run \
    -it  \
    --rm \
    --network=${NETWORK} \
    --name cli \
    -p 12051:7051 \
    -p 12053:7053 \
    -e NACCOUNTS=${NACCOUNTS} \
    -e MONEY=${MONEY} \
    -e CHANNEL_NAME=${CHANNEL_NAME} \
    -e CHAINCODE_NAME=${CHAINCODE_NAME} \
    -e CHAINCODE=${CHAINCODE} \
    -e INSTANTIATION_PEER=${INSTANTIATION_PEER} \
    -e GOPATH=/opt/gopath \
    -e CORE_PEER_LOCALMSPID=Org1MSP \
    -e CORE_PEER_TLS_ENABLED=false \
    -e CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock \
    -e CORE_LOGGING_LEVEL=info \
    -e CORE_PEER_ID=cli \
    -e CORE_PEER_ADDRESS=peer0.org1.example.com:7051 \
    -e CORE_CHAINCODE_DEPLOYTIMEOUT=300s \
    -e CORE_CHAINCODE_STARTUPTIMEOUT=300s \
    -e CORE_PEER_NETWORKID=cli \
    -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp \
    -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=${NETWORK} \
    -v /var/run/:/host/var/run/ \
    -v $(pwd)/chaincode/:/opt/gopath/src/github.com/hyperledger/fabric/examples/chaincode/go \
    -v $(pwd)/crypto-config:/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ \
    -v $(pwd)/scripts:/opt/gopath/src/github.com/hyperledger/fabric/peer/scripts/ \
    -v $(pwd)/channel-artifacts/${CHANNEL_NAME}:/opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts \
    -w /opt/gopath/src/github.com/hyperledger/fabric/peer \
    hyperledger/fabric-tools \
    /bin/bash -c './scripts/script.sh'

cd ..
