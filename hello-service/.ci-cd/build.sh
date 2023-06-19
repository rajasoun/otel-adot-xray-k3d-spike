#!/usr/bin/env bash 

docker build -t hello-service:latest .
docker tag hello-service:latest registry.dev.local.gd:5001/hello-service:latest
