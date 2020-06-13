#!/usr/bin/env bash

set -o xtrace

USAGE="\
usage: $0 [local|remote] [up|down|restart|status]
"

### Main ###
if [ $# -ne 2 ];
then
	>&2 echo ${USAGE};
	exit 1;
fi

rm -rf src/hfc-key-store

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

./network.sh $2

cd ..
