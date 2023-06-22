#!/usr/bin/env bash

# Color variables
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
NC=$(tput sgr0) # No Color

# Retrieves pod information including names, container names, and ports
function get_pod_ports() {
  local namespace=$1
  printf "${GREEN}Namespace: %s${NC}\n" "$namespace"
  kubectl get pods --namespace "$namespace" -o jsonpath='{range .items[*]}'"${GREEN}Pod Name: ${NC}"'{.metadata.name}{"\n"}{range .spec.containers[*]}'"${YELLOW} Container Name: ${NC}"'{.name}{"\n"}'"${YELLOW} Port(s): ${NC}"'{range .ports[*]}{.containerPort}{","}{end}{"\n"}{end}{"\n"}{end}' 
}

# Main function that orchestrates the execution flow
function main() {
  local namespace=${1:-default}
  get_pod_ports "$namespace"
}

main "$@"
