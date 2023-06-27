#!/usr/bin/env bash 

docker tag hello-service:latest registry.dev.local.gd:5001/hello-service:latest
docker push registry.dev.local.gd:5001/hello-service:latest
# docker rmi registry.dev.local.gd:5001/hello-service:latest