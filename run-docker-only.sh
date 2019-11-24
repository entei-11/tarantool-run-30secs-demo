#!/bin/bash

printf "Cleaning...\n"

docker stop test_tarantool_docker_only
docker rm test_tarantool_docker_only

printf "Starting...\n"

# Comment the line below if you're not using linus
cwd=$PWD

# Uncomment the line below if you're using cygwin
#cwd=$(cygpath -w "$PWD")

docker run --name test_tarantool_docker_only -p3307:3301 -d -v "$cwd":"/opt/tarantool" tarantool/tarantool:2.1.2 tarantool /opt/tarantool/test_healthy_tarantool.lua

printf "Testing...\n"

try=0
retryCount=30

while [ -z "$healtyTarantoolContainer" ];
do
  try=$try+1
  if (( $try > $retryCount ));
  then
    printf "Container hasn't been started\n"

    docker stop test_tarantool_docker_only
    docker rm test_tarantool_docker_only

    exit 712
  fi

  if (( $try > 1 ));
  then
    sleep 1;
  fi

  healtyTarantoolContainer=$(docker container ls -a -f health=healthy -f name="test_tarantool_docker_only" -q)

  containerStatus=$(docker container ls -a -f name="test_tarantool_docker_only" | grep "test_tarantool_docker_only")

  printf "$containerStatus\n"

  if ( echo $containerStatus | grep -i "exited" ); then
      printf "Container has been started and then it exited\n"

      docker stop test_tarantool_docker_only
      docker rm test_tarantool_docker_only

      exit 713
  fi

  docker run --rm tarantool/tarantool:2.1.2 tarantoolctl connect host.docker.internal:3307

# Uncomment the line below to see the port is not exposed
#  netstat -na | grep 3307

done
