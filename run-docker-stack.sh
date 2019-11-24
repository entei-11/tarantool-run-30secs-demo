#!/bin/bash

printf "Cleaning...\n"

docker stack rm test_docker_stack

sleep 10

exitedContainers=$(docker container ls -a -f status=exited -f name="test_docker_stack_" -q)
if [ ! -z "$exitedContainers" ];
then
  docker container rm $exitedContainers
fi

printf "Starting...\n"

docker stack deploy -c test_docker_stack.yml test_docker_stack

sleep 10

printf "Testing...\n"

try=0
retryCount=30

while [ -z "$healtyTarantoolContainer" ];
do
  try=$try+1
  if (( $try > $retryCount ));
  then
    printf "Container hasn't been started\n"

    docker stack rm test_docker_stack

    exit 712
  fi

  if (( $try > 1 ));
  then
    sleep 1;
  fi

  healtyTarantoolContainer=$(docker container ls -a -f health=healthy -f name="test_docker_stack_" -q)

  containerStatus=$(docker container ls -a -f name="test_docker_stack_" | grep "test_docker_stack_")

  printf "$containerStatus\n"

  if ( echo $containerStatus | grep -i "exited" ); then
      printf "Container has been started and then it exited\n"

      docker stack rm test_docker_stack

      exit 713
  fi

  docker run --rm tarantool/tarantool:2.1.2 tarantoolctl connect host.docker.internal:3308

# Uncomment the line below to see the port is not exposed
#  netstat -na | grep 3308

done
