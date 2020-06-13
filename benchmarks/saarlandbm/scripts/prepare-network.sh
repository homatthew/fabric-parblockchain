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

: ${CHAINCODE:="smallbank"}
: ${NACCOUNTS:=10000}
: ${NCHANNELS:=1}
: ${CHANNEL_NAME:="channel"}
: ${INSTANTIATION_PEER:=0}


echo "waiting for 5s before initializing the chaincode on channel=${CHANNEL_NAME}"
CHANNEL_NAME="${CHANNEL_NAME}" ./scripts/prepare-artifacts.sh $1
sleep 5
INSTANTIATION_PEER=${INSTANTIATION_PEER} CHAINCODE=${CHAINCODE} NACCOUNTS=${NACCOUNTS} CHANNEL_NAME="${CHANNEL_NAME}" CHAINCODE_NAME="${CHANNEL_NAME}c" ./scripts/chaincode.sh $1
echo "done initializing chaincode on channel=${CHANNEL_NAME}"
echo
