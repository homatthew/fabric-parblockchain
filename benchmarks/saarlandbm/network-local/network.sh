#!/usr/bin/env bash

USAGE="\
usage: $0 [up|down|restart|status]
"

function cleanup
{
    # STOP AND DELETE THE DOCKER CONTAINERS
    docker ps -aq | xargs -n 1 docker stop 2> /dev/null
    docker ps -aq | xargs -n 1 docker rm -v 2> /dev/null

    # remove all containers
    docker container ls -aq | xargs docker container rm 2> /dev/null

    # DELETE THE OLD DOCKER VOLUMES
    yes | docker volume prune 2> /dev/null

    # remove all images
    # docker images -aq | xargs docker image rm --force 2> /dev/null

    # DELETE OLD DOCKER NETWORKS (OPTIONAL: seems to restart fine without)
    #docker network prune 2> /dev/null

    # DELETE SCRIPT-CREATED FILES
    # rm -rf channel-artifacts/*.block channel-artifacts/*.tx crypto-config
    # rm -f docker-compose-e2e.yaml
    rm -rf ../src/hfc-key-store
    rm -rf channel-artifacts/msp
    rm -rf channel-artifacts/channel*
}

function status
{
    docker ps -a
}

function up
{
    docker-compose -p networklocal -f docker-compose.yaml up -d &>/dev/null
}

function down
{
    cleanup
}

### Main ###
if [ $# -ne 1 ];
then
	>&2 echo ${USAGE};
	exit 1;
fi

ret=0

case "$1" in
	"up")
		up;
		status;
		;;
	"down")
		down;
		status;
		;;
	"restart")
		down;
		up;
		status;
		;;
	"status")
		status;
		;;
	*)
		>&2 echo ${USAGE};
		ret=1;
		;;
esac

exit $ret
