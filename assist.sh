#!/usr/bin/env bash

set -eo pipefail
IFS=$'\n\t'

GIT_BASE_PATH=$(git rev-parse --show-toplevel)
SCRIPT_LIB_DIR="$GIT_BASE_PATH/scripts/lib"

# Overview function
function overview() {
    echo "Automated Script Overview:"
    echo "1. Create a Local Kubernetes Cluster"
    echo "2. Create Secrets"
    echo "3. Bootstrap the Cluster"
    echo "4. Retrieve Pod and Container Information"
    echo "5. Build, Push, and Deploy the hello-service"
    echo "6. Access the hello-service"
    echo "7. Visit the AWS X-Ray Console"
    echo
}

# precheck function
function prechecks(){
    scripts/wrapper.sh run check_aws_profile_exists || return 1
    scripts/wrapper.sh run check_local_aws_token_expiration_time || return 1
}

# Step 1: Create a Local Kubernetes Cluster
function create_local_cluster() {
    local-dev/assist.sh setup
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

# Step 3: Bootstrap the Cluster
function bootstrap_cluster() {
    kubectl apply -k bootstrap
}

# Step 4: Retrieve Pod and Container Information
function retrieve_pod_container_info() {
    bootstrap/debug.sh default
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
    # Navigate to the AWS X-Ray console as specified
    local region=$(yq e '.data."otel-local-config.yaml" | select(. != null)' bootstrap/aws-otel-collector/config.yaml | yq e '.exporters.awsxray.region' -)
    local xray_console_url="https://$region.console.aws.amazon.com/cloudwatch/home?region=$region#xray:traces/query"

    pretty_print "${BOLD}Visit the AWS X-Ray Console${NC}\n"
    pretty_print "${YELLOW}URL:${NC} ${BLUE}$xray_console_url${NC}\n"
}


function setup() {
    #overview
    prechecks
    create_local_cluster
    create_secrets
    bootstrap_cluster
}

function teardown() {
    local-dev/assist.sh teardown
}

function status() {
    retrieve_pod_container_info
    scripts/wrapper.sh run check_aws_token_expiration_time
}

function test() {
    build_push_deploy_hello_service
    access_hello_service
    visit_xray_console
}


# Execute main function
source "${SCRIPT_LIB_DIR}/main.sh" $@
