#!/bin/bash

# STOP AND DELETE THE DOCKER CONTAINERS
docker ps -aq | xargs -n 1 docker stop &> /dev/null
docker ps -aq | xargs -n 1 docker rm -v &> /dev/null

# remove all containers
docker container ls -aq | xargs docker container rm &> /dev/null

# remove all images
# docker images -aq | xargs docker image rm --force &> /dev/null

# DELETE THE OLD DOCKER VOLUMES
docker volume prune &> /dev/null

# DELETE OLD DOCKER NETWORKS (OPTIONAL: seems to restart fine without)
#docker network prune 2> /dev/null

# DELETE SCRIPT-CREATED FILES
# rm -rf channel-artifacts/*.block channel-artifacts/*.tx crypto-config
# rm -f docker-compose-e2e.yaml

# VERIFY RESULTS
# docker ps -a &> /dev/null
# docker volume ls &> /dev/null
