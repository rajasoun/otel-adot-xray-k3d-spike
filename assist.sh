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

# Step 3: Bootstrap common in Cluster
function bootstrap_common_in_cluster() {
    kubectl apply -k bootstrap/k8s/common
}

# Step 3a: Bootstrap otel aws in the Cluster
function bootstrap_otel_aws_in_cluster() {
    kubectl apply -k bootstrap/k8s/otel-aws-collector-xray
}

# Step 3b: Bootstrap otel operator + collector + jaeger in the Cluster
function bootstrap_otel_ecosystem_in_cluster() {
    kubectl apply -k bootstrap/k8s/otel-operator-collector-jaeger
}

# Step 4: Retrieve Pod and Container Information
function retrieve_pod_container_info() {
    bootstrap/k8s/debug.sh default
}

# Step 5: Build, Push, and Deploy the hello-service
function build_push_deploy_hello_service() {
    cd hello-service
    .ci-cd/build.sh
    .ci-cd/push.sh
    .ci-cd/deploy.sh
}

# Step 6: Access the hello-service
function access_hello_service() {
    http http://hello.local.gd
    http http://hello.local.gd/otel
}

# Step 7: Visit the AWS X-Ray Console
function visit_xray_console() {
    local region=$(yq e '.data."otel-local-config.yaml" | select(. != null)' "${GIT_BASE_PATH}/bootstrap/k8s/aws-otel-collector/config.yaml" | yq e '.exporters.awsxray.region' -)
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
        echo -e "${RED}Option is empty or is neither 'aws' nor 'otel'${NC}"
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

    perform_prechecks
    create_local_cluster
    create_secrets
    bootstrap_common_in_cluster

    case "$option" in
        "aws")
            bootstrap_otel_aws_in_cluster
            ;;
        "otel")
            bootstrap_otel_ecosystem_in_cluster
            ;;
    esac
}

# Teardown function
function teardown() {
    local-dev/assist.sh teardown
}

# Get status function
function get_status() {
    retrieve_pod_container_info
    scripts/wrapper.sh run check_aws_token_expiration_time
}

# Run tests
function run_tests() {
    build_push_deploy_hello_service
    access_hello_service
    visit_xray_console
}

# Execute main function
source "${SCRIPT_LIB_DIR}/main.sh" "$@"
