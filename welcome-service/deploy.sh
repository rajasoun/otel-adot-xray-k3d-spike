#!/usr/bin/env bash

kubectl create deployment welcome --image=nginx:latest --port=80
kubectl expose deployment welcome
kubectl create ingress welcome-local-gd --class=nginx  --rule="welcome.local.gd/*=welcome:80"
http http://welcome.local.gd


kubectl delete deployment welcome 
kubectl delete service welcome
kubectl delete ingress welcome-local-gd 