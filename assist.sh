#!/usr/bin/env bash

set -eo pipefail
IFS=$'\n\t'

GIT_BASE_PATH=$(git rev-parse --show-toplevel)
SCRIPT_LIB_DIR="$GIT_BASE_PATH/scripts/lib"

# Print section headers
function print_section_header() {
    echo "$1"
    echo
}

# Step 1: Create a Local Kubernetes Cluster
function create_local_cluster() {
    local-dev/assist.sh setup
    kubectx k3d-dev
}

# Step 2: Create Secrets
function create_secrets() {
    # Option 1: Create secret directly
    kubectl create secret generic aws-credentials --from-file="$HOME/.aws/credentials"

    # Option 2: Create secret using wrapper script
    scripts/wrapper.sh run create_secrets_in_cluster_from_aws_credential_file
    #scripts/wrapper.sh run view_aws_credentials_from_cluster
    #scripts/wrapper.sh run check_aws_token_expiration_time
    #scripts/wrapper.sh run delete_aws_credentials_from_cluster
}

# Step 3: Bootstrap base in Cluster
function bootstrap_base_in_cluster() {
    kubectl apply -k bootstrap/k8s/base
    wait_till_all_pods_are_ready_with_message "opentelemetry-operator-system" "opentelemetry-operator" 
}

# Step 3a: Bootstrap otel aws in the Cluster
function bootstrap_aws_adot_collection_in_cluster() {
    kubectl apply -k bootstrap/k8s/aws-adot-collector-xray
}

# Step 3b: Bootstrap otel operator + collector + jaeger in the Cluster
function bootstrap_otel_collector_in_cluster() {
    kubectl apply -k bootstrap/k8s/otel-collector-jaeger
}

# Step 4: Retrieve Pod and Container Information
function retrieve_pod_container_info() {
    bootstrap/k8s/debug.sh default
}

# Step 5: Build, Push, and Deploy the hello-service
function build_push_deploy_hello_service() {
    make -f hello-service/.ci-cd/Makefile build-push-deploy
}

# Step 6: Access the hello-service
function access_hello_service() {
    http http://hello.local.gd
    http http://hello.local.gd/otel
}

# Step 7: Visit the AWS X-Ray Console
function visit_xray_console() {
    # Check if aws-otel-collector pod is running
    if ! kubectl get pod -l app=aws-otel-collector -o name | grep -q '^pod/aws-otel-collector'; then
        exit 1
    fi

    local region=$(yq e '.data."otel-local-config.yaml" | select(. != null)' "${GIT_BASE_PATH}/bootstrap/k8s/aws-adot-collector-xray/config.yaml" | yq e '.exporters.awsxray.region' -)
    local xray_console_url="https://$region.console.aws.amazon.com/cloudwatch/home?region=$region#xray:traces/query"

    print_section_header "Visit the AWS X-Ray Console"
    echo "URL: $xray_console_url"
    echo
}

# Perform prechecks before setup
function perform_prechecks() {
    scripts/wrapper.sh run check_local_aws_token_expiration_time || return 1
}

# Setup function
function setup() {   
    local option="$2"
    if [[ -z "$option" || ("$option" != "aws" && "$option" != "otel") ]]; then
        echo -e "${RED}Option is empty or is neither 'aws' or 'otel'${NC}"
        return 1
    fi

    print_section_header "Automated Script Overview"
    echo "1. Create a Local Kubernetes Cluster"
    echo "2. Create Secrets"
    echo "3. Bootstrap the Cluster"
    echo "4. Retrieve Pod and Container Information"
    echo "5. Build, Push, and Deploy the hello-service"
    echo "6. Access the hello-service"
    echo "7. Visit the AWS X-Ray Console"
    echo

    case "$option" in
        "aws")
            perform_prechecks
            create_local_cluster
            bootstrap_base_in_cluster
            create_secrets
            bootstrap_aws_adot_collection_in_cluster
            ;;
        "otel")
            create_local_cluster
            bootstrap_base_in_cluster
            bootstrap_otel_collector_in_cluster
            ;;
    esac
}

# Teardown function
function teardown() {
    local-dev/assist.sh teardown
}

# Get status function
function status() {
    retrieve_pod_container_info
    scripts/wrapper.sh run check_aws_token_expiration_time
}

# Run tests
function test() {
    build_push_deploy_hello_service
    access_hello_service
    visit_xray_console
}

# Execute main function
source "${SCRIPT_LIB_DIR}/main.sh" "$@"
