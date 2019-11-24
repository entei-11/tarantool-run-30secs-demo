# tarantool-run-30secs-demo

This repo demonstrates the issue I faced. I found out that I can't access tarantool for 30 seconds after I start Tarantool in the docker swarm. After several tests I found out that a forwarded port for the stack is not exposed until the tarantool docker container becomes in the "healthy" state. Also, I found out that transition from the "starting" state to "healthy" takes exactly 30 seconds that I have to wait.

A tarantool docker container that I start directly by using run-command exposes the forwarded port immediately after it runs into the "starting" state. So, I believe that the issue is caused by combination of the long tansition from "starting" to "healthy" states and some specific behaviour of the docker container hosted by the docker swarm.

## Scripts to reproduce the issue.

Use `run-docker-only.sh` to start a tarantool container by `docker run`. You can see that for 30 seconds it stays in the "starting" state and then goes to the "healthy" state. And all that time you can connect to the tarantool from the outside.
``` bash
bash run-docker-only.sh
```
Use `run-docker-stack.sh` to start a tarantool container into the swarm by `docker stack deploy`. Here you can see the same state transition that lasts 30 seconds. But the tarantool becomes available from the outside just after the tarantool becomes healthy.
``` bash
bash run-docker-only.sh
```
