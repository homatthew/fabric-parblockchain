#!/bin/bash

set -e
set -o xtrace

: ${NETWORK="local"}
: ${BRANCH:="baseline"}
: ${NACCOUNTS:=100000}

CANAME="ca.org1.example.com"
CAADDR=
PADDR=
OADDR=
PPORT=
OPORT=

if [ ${NETWORK} == "local" ]; then
    PADDR="localhost"
    OADDR="localhost"
    CAADDR="localhost"
    PPORT=8051
    OPORT=7050
else
    OADDR="orderer.example.com"
    CAADDR="ca.org1.example.com"
    PADDR="peer0.org1.example.com"
    PPORT=7051
    OPORT=7050
fi

for MaxMessageCount in 1024 512 256 128;
do
    echo "Starting config generation ..."
    if [ ${BRANCH} == "baseline" ]; then
        MaxMessageCount=${MaxMessageCount} ./scripts/template-gen.sh ${NETWORK}
    else
        MaxUniqueKeys=16384 MaxMessageCount=${MaxMessageCount} ./scripts/template-gen.sh ${NETWORK}
    fi
    echo "Config generation completed"

    sleep 2
    echo "Generating the Orderer genesis block"
    cd network-${NETWORK}
    ./artifacts.sh genesis
    cd ..
    echo "Done generating orderer genesis.block"

    sleep 2

    for nchannel in 1;
    do
      for s in 1 2 3 4;
      do
        for writePer in 1 2 3 4;
        do
          echo "Starting network ... "
          ./scripts/network.sh ${NETWORK} restart
          echo "Network is up ....."

          echo "sleep for 15s before starting the experiment"
          sleep 15

          rm -rf src/hfc-key-store
          readPer=`expr 100 - 5 \* ${writePer}`
          echo "Prepare network starting... "
          CHANNEL_PREFIX="ch`openssl rand -hex 3`"
          echo "[${CHANNEL_PREFIX} =>  ${BRANCH},${MaxMessageCount},${readPer},${writePer}]"
          NACCOUNTS=${NACCOUNTS} NCHANNELS=${nchannel} CHANNEL_NAME=${CHANNEL_PREFIX} ./scripts/prepare-network.sh ${NETWORK}
          echo "Prepare network completed ..."

          sleep 5
          #start the benchmark
          for i  in `seq 1 4`;
          do
            user="u{i}`openssl rand -hex 2`"
            node src/benchmark.js --zipfs=${s} --bmark=smallbank --transact=${writePer} --deposit=${writePer} --payment=${writePer} --check=${writePer} --amalgamate=${writePer} --query=${readPer} --caname=ca.org1.example.com --user=${user} --caaddr=ca.org1.example.com --caport=7054 --mspid=Org1MSP --channelName=${CHANNEL_PREFIX} --naccounts=${NACCOUNTS} --paddr=peer0.org1.example.com --pport=7051 --oaddr=orderer.example.com --oport=7050 --gap=3m --duration=90s &
          done

          wait
          echo
          echo "waiting 15s to wrapup previous experiment's transactions..."
          sleep 15
          # copy logs to logs/
          FOLDER_NAME=${BRANCH}_${MaxMessageCount}_${s}_${readPer}
          mkdir -p logs/${FOLDER_NAME}
          if [ ${NETWORK} == "local" ]; then
            docker logs peer0.org1.example.com >& logs/${FOLDER_NAME}/peer0-org1.log
            docker logs peer1.org1.example.com >& logs/${FOLDER_NAME}/peer1-org1.log
            docker logs peer0.org2.example.com >& logs/${FOLDER_NAME}/peer0-org2.log
            docker logs peer1.org2.example.com >& logs/${FOLDER_NAME}/peer1-org2.log
            docker logs orderer.example.com >& logs/${FOLDER_NAME}/orderer.log
          else
            mv /var/nfs/logs/*.log logs/${FOLDER_NAME}
          fi

        done
      done
    done
    ./scripts/network.sh ${NETWORK} down
done
