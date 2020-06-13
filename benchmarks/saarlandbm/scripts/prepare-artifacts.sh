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

: ${NCHANNELS:=1}
: ${CHANNEL_NAME:= channel_1}

case "$1" in
	"local")
		cd network-local;
		;;
	"remote")
		cd network-remote;
		;;
	*)
		>&2 echo ${USAGE};
		exit 1;
		;;
esac

CHANNEL_NAME=${CHANNEL_NAME} ./artifacts.sh channel

cd ..
