#!/bin/bash

#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This script will orchestrate a sample end-to-end execution of the Hyperledger
# Fabric network.
#
# The end-to-end verification provisions a sample Fabric network consisting of
# two organizations, each maintaining two peers, and a “solo” ordering service.
#
# This verification makes use of two fundamental tools, which are necessary to
# create a functioning transactional network with digital signature validation
# and access control:
#
# * cryptogen - generates the x509 certificates used to identify and
#   authenticate the various components in the network.
# * configtxgen - generates the requisite configuration artifacts for orderer
#   bootstrap and channel creation.
#
# Each tool consumes a configuration yaml file, within which we specify the topology
# of our network (cryptogen) and the location of our certificates for various
# configuration operations (configtxgen).  Once the tools have been successfully run,
# we are able to launch our network.  More detail on the tools and the structure of
# the network will be provided later in this document.  For now, let's get going...

# prepending $PWD/../bin to PATH to ensure we are picking up the correct binaries
# this may be commented out to resolve installed version of tools if desired

USAGE="\
usage: $0 [certs|genesis|channel]
    "

if [ $# -ne 1 ]; then
    >&2 echo ${USAGE}
fi

export PATH=${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}

: ${CHANNEL_NAME="mychannel"}

# Generates Org certs using cryptogen tool
function generateCerts (){
    which cryptogen
    if [ "$?" -ne 0 ]; then
        echo "cryptogen tool not found. exiting"
        exit 1
    fi
    echo
    echo "##########################################################"
    echo "##### Generate certificates using cryptogen tool #########"
    echo "##########################################################"
    if [ -d "crypto-config" ]; then
        rm -Rf crypto-config
    fi
    cryptogen generate --config=./crypto-config.yaml
    if [ "$?" -ne 0 ]; then
        echo "Failed to generate certificates..."
        exit 1
    fi
    echo
}

function generateGenesisBlock() {
    which configtxgen
    if [ "$?" -ne 0 ]; then
        echo "configtxgen tool not found. exiting"
        exit 1
    fi

    if [ -d "./channel-artifacts" ]; then
        rm -rf ./channel-artifacts
    fi

    mkdir -p ./channel-artifacts

    echo "##########################################################"
    echo "#########  Generating Orderer Genesis block ##############"
    echo "##########################################################"
    # Note: For some unknown reason (at least for now) the block file can't be
    # named orderer.genesis.block or the orderer will fail to launch!
    configtxgen -profile TwoOrgOrdererGenesis -outputBlock ./channel-artifacts/genesis.block
    if [ "$?" -ne 0 ]; then
        echo "Failed to generate orderer genesis block..."
        exit 1
    fi
}

function generateChannelArtifacts() {
    which configtxgen
    if [ "$?" -ne 0 ]; then
        echo "configtxgen tool not found. exiting"
        exit 1
    fi

    if [ -d "./channel-artifacts/${CHANNEL_NAME}" ]; then
        rm -rf "./channel-artifacts/${CHANNEL_NAME}"
    fi

    mkdir -p "./channel-artifacts/${CHANNEL_NAME}"

    echo "#################################################################"
    echo "### Generating channel configuration transaction 'channel.tx' ###"
    echo "#################################################################"
    configtxgen -profile TwoOrgChannel -outputCreateChannelTx "./channel-artifacts/${CHANNEL_NAME}/channel.tx" -channelID $CHANNEL_NAME
    if [ "$?" -ne 0 ]; then
        echo "Failed to generate channel configuration transaction..."
        exit 1
    fi

    echo
    echo "#################################################################"
    echo "#######    Generating anchor peer update for Org1MSP   ##########"
    echo "#################################################################"
    configtxgen -profile TwoOrgChannel -outputAnchorPeersUpdate "./channel-artifacts/${CHANNEL_NAME}/Org1MSPanchors.tx" -channelID $CHANNEL_NAME -asOrg Org1MSP
    if [ "$?" -ne 0 ]; then
        echo "Failed to generate anchor peer update for Org1MSP..."
        exit 1
    fi
    echo

    echo
    echo "#################################################################"
    echo "#######    Generating anchor peer update for Org2MSP   ##########"
    echo "#################################################################"
    configtxgen -profile TwoOrgChannel -outputAnchorPeersUpdate "./channel-artifacts/${CHANNEL_NAME}/Org2MSPanchors.tx" -channelID $CHANNEL_NAME -asOrg Org2MSP
    if [ "$?" -ne 0 ]; then
        echo "Failed to generate anchor peer update for Org2MSP..."
        exit 1
    fi
    echo
}


# Obtain the OS and Architecture string that will be used to select the correct
# native binaries for your platform
OS_ARCH=$(echo "$(uname -s|tr '[:upper:]' '[:lower:]'|sed 's/mingw64_nt.*/windows/')-$(uname -m | sed 's/x86_64/amd64/g')" | awk '{print tolower($0)}')
# timeout duration - the duration the CLI should wait for a response from
# another container before giving up
CLI_TIMEOUT=10
#default for delay
CLI_DELAY=3
# channel name defaults to "mychannel"

EXPMODE="Generating certs and genesis block for"

# Announce what was requested

# echo "${EXPMODE} with channel '${CHANNEL_NAME}' and CLI timeout of '${CLI_TIMEOUT}'"

# generate crypto-material

case "$1" in
    "certs")
        generateCerts;
        ;;
    "genesis")
        generateGenesisBlock;
        ;;
    "channel")
        generateChannelArtifacts;
        ;;
    *)
        >&2 echo ${USAGE};
        exit 1;
        ;;
esac
