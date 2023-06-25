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

echo -e "\n${YELLOW}Checking for ingress-nginx-controller service...${NC}"
kubectl get service ingress-nginx-controller --namespace=ingress-nginx


echo -e "\n${YELLOW}ingress-nginx-controller version...${NC}"
POD_NAMESPACE=ingress-nginx
POD_NAME=$(kubectl get pods -n $POD_NAMESPACE -l app.kubernetes.io/name=ingress-nginx --field-selector=status.phase=Running -o name)
kubectl exec $POD_NAME -n $POD_NAMESPACE -- /nginx-ingress-controller --version