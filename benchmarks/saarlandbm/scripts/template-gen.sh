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

DOCKER=0

case "$1" in
    "local")
        cd network-local;
        DOCKER=1;
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



: ${BatchTimeout:="1s"}
: ${MaxMessageCount:=256}
: ${AbsoluteMaxBytes:="64 MB"}
: ${PreferredMaxBytes:="12 MB"}
: ${MaxUniqueKeys:=0}

CA1Key=`ls ./crypto-config/peerOrganizations/org1.example.com/ca/ | grep "_sk"`
CA2Key=`ls ./crypto-config/peerOrganizations/org2.example.com/ca/ | grep "_sk"`

SED_APPEND=

if [ `uname` == Darwin ]; then
    SED_APPEND="\'\'"
fi

echo "generating configtx.yaml ..."
sed "s/BatchTimeoutTag/BatchTimeout: $BatchTimeout/g" "configtx-template.yaml" > "configtx-gen.yaml"
sed -i $SED_APPEND "s/MaxMessageCountTag/MaxMessageCount: $MaxMessageCount/g" "configtx-gen.yaml"
sed -i $SED_APPEND "s/AbsoluteMaxBytesTag/AbsoluteMaxBytes: $AbsoluteMaxBytes/g" "configtx-gen.yaml"
sed -i $SED_APPEND "s/PreferredMaxBytesTag/PreferredMaxBytes: $PreferredMaxBytes/g" "configtx-gen.yaml"

if [ $MaxUniqueKeys -eq 0 ]; then
    sed -i $SED_APPEND "s/MaxUniqueKeysTag//g" "configtx-gen.yaml"
else
    sed -i $SED_APPEND "s/MaxUniqueKeysTag/MaxUniqueKeys: $MaxUniqueKeys/g" "configtx-gen.yaml"
fi

mv configtx-gen.yaml configtx.yaml
echo "successfully generated templated configtx.yaml"

if [ $DOCKER -eq 1 ]; then
    echo "generating the docker-compose.yaml ..."
    sed "s/CA1KeyTag/$CA1Key/g" "docker-compose-template.yaml" > docker-compose.yaml
    sed -i $SED_APPEND "s/CA2KeyTag/$CA2Key/g" "docker-compose.yaml"
fi

cd ..
