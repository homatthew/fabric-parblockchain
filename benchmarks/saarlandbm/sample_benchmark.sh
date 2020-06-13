#!/bin/bash

: ${CHANNEL_PREFIX:=channel}
: ${NACCOUNTS:=10000}

# node src/benchmark.js --caname=ca.org1.example.com --caaddr=ca.org1.example.com --caport=7054 --mspid=Org1MSP --channelPrefix=${CHANNEL_PREFIX} --naccounts=${NACCOUNTS} --paddr=peer0.org1.example.com --pport=7051 --oaddr=orderer.example.com --oport=7050 --gap=2m --duration=60s --readWrite=8 --readPer=50 --writePer=10 --hotness=0.001

user="u`openssl rand -hex 2`"
#node src/benchmark.js --caname=ca.org1.example.com --user=${user} --caaddr=ca.org1.example.com --caport=7054 --mspid=Org1MSP --channelName=${CHANNEL_PREFIX} --naccounts=${NACCOUNTS} --paddr=peer0.org1.example.com --pport=7051 --oaddr=orderer.example.com --oport=7050 --gap=2m --duration=60s --readWrite=8 --readPer=50 --writePer=10 --hotness=0.001
# node src/benchmark.js --caname=ca.org1.example.com --user=user11 --caaddr=localhost --caport=7054 --mspid=Org1MSP --channelName=${CHANNEL_PREFIX} --naccounts=${NACCOUNTS} --paddr=localhost --pport=8051 --oaddr=localhost --oport=7050 --gap=2m --duration=60s --readWrite=8 --readPer=50 --writePer=10 --hotness=0.001
# node src/benchmark.js --caname=ca.org1.example.com --user=user11 --caaddr=localhost --caport=7054 --mspid=Org1MSP --channelName=${CHANNEL_PREFIX} --naccounts=${NACCOUNTS} --paddr=localhost --pport=8051 --oaddr=localhost --oport=7050 --gap=2m --duration=60s --readWrite=8 --readPer=50 --writePer=10 --hotness=0.001

# node src/benchmark.js --zipfs=1 --bmark=smallbank --transact=10 --deposit=20 --payment=30 --check=10 --amalgamate=20 --query=10 --caname=ca.org1.example.com --user=${user} --caaddr=localhost --caport=7054 --mspid=Org1MSP --channelName=${CHANNEL_PREFIX} --naccounts=${NACCOUNTS} --paddr=localhost --pport=8051 --oaddr=localhost --oport=7050 --gap=2m --duration=60s --readWrite=8 --readPer=50 --writePer=10 --hotness=0.001
node src/benchmark.js --zipfs=1 --bmark=smallbank --transact=10 --deposit=20 --payment=30 --check=10 --amalgamate=20 --query=10 --caname=ca.org1.example.com --user=${user} --caaddr=ca.org1.example.com --caport=7054 --mspid=Org1MSP --channelName=${CHANNEL_PREFIX} --naccounts=${NACCOUNTS} --paddr=peer0.org1.example.com --pport=7051 --oaddr=orderer.example.com --oport=7050 --gap=1s --duration=60s --readWrite=8 --readPer=50 --writePer=10 --hotness=0.001
