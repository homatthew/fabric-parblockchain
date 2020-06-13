#!/bin/bash

USAGE="\
usage: $0 [up|down|restart|status]
"

: ${LOGGING_LEVEL:=info}

function status
{
	echo -e "container_id\tname"
	for x in 01 03 04 07 08;
	do
		ssh "hail$x" "docker ps --format \"{{.ID}} \t {{.Names}}\"";
	done
}

function up
{
	ssh -a -x hail01 "tmux new -s ca-org1 -d /bin/bash -c 'cd /var/nfs/benchmark-fabric/network-remote/; LOGGING_LEVEL=${LOGGING_LEVEL} ./ca.org1.example.com.sh; read;'"
	ssh -a -x hail04 "tmux new -s ca-org2 -d /bin/bash -c 'cd /var/nfs/benchmark-fabric/network-remote/; LOGGING_LEVEL=${LOGGING_LEVEL} ./ca.org2.example.com.sh; read;'"
	sleep 5;
	ssh -a -x hail08 "tmux new -s orderer -d /bin/bash -c 'cd /var/nfs/benchmark-fabric/network-remote/; LOGGING_LEVEL=${LOGGING_LEVEL} ./orderer.example.com.sh | tee /var/nfs/logs/orderer.log; read;'"
	sleep 5;
    # Hail01
	ssh -a -x hail01 "tmux new -s peer0-org1 -d /bin/bash -c 'cd /var/nfs/benchmark-fabric/network-remote/; LOGGING_LEVEL=${LOGGING_LEVEL} ./peer0.org1.example.com.sh | tee /var/nfs/logs/peer0-org1.log; read;'"
    # Hail03
	ssh -a -x hail03 "tmux new -s peer1-org1 -d /bin/bash -c 'cd /var/nfs/benchmark-fabric/network-remote/; LOGGING_LEVEL=${LOGGING_LEVEL} ./peer1.org1.example.com.sh | tee /var/nfs/logs/peer1-org1.log; read;'"
    #Hail04
	ssh -a -x hail04 "tmux new -s peer0-org2 -d /bin/bash -c 'cd /var/nfs/benchmark-fabric/network-remote/; LOGGING_LEVEL=${LOGGING_LEVEL} ./peer0.org2.example.com.sh | tee /var/nfs/logs/peer0-org2.log; read;'"
    # Hail07
	ssh -a -x hail07 "tmux new -s peer1-org2 -d /bin/bash -c 'cd /var/nfs/benchmark-fabric/network-remote/; LOGGING_LEVEL=${LOGGING_LEVEL} ./peer1.org2.example.com.sh | tee /var/nfs/logs/peer1-org2.log; read;'"
}

function down
{
	ssh -a -x hail01 "tmux kill-session -t ca-org1; \
                      tmux kill-session -t peer0-org1; \
                      yes | /var/nfs/benchmark-fabric/network-remote/cleanup.sh;" &
	ssh -a -x hail03 "tmux kill-session -t peer1-org1; \
                      yes | /var/nfs/benchmark-fabric/network-remote/cleanup.sh;" &
	ssh -a -x hail04 "tmux kill-session -t ca-org2; \
                      tmux kill-session -t peer0-org2; \
                      yes | /var/nfs/benchmark-fabric/network-remote/cleanup.sh;" &
	ssh -a -x hail07 "tmux kill-session -t peer1-org2; \
                      yes | /var/nfs/benchmark-fabric/network-remote/cleanup.sh;" &
	ssh -a -x hail08 "tmux kill-session -t orderer; \
                      yes | /var/nfs/benchmark-fabric/network-remote/cleanup.sh;" &
	wait;
}

### Main ###
if [ $# -ne 1 ];
then
	>&2 echo ${USAGE};
	exit 1;
fi

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
		exit 1;
		;;
esac

