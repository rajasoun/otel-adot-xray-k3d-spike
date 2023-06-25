#!/usr/bin/env bash

# Color variables
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
NC=$(tput sgr0) # No Color
BOLD=$'\033[1m'
BLUE=$'\e[34m'

set -e
echo -e "${YELLOW}Checking pods in ingress-nginx namespace...${NC}"
kubectl get pods --namespace=ingress-nginx
echo -e "\n${YELLOW}Checking for ingress-nginx to be ready...${NC}"
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s