#!/usr/bin/env bash

# Constants
readonly DEFAULT_AWS_CREDENTIALS_FILE="$HOME/.aws/credentials"
readonly DEFAULT_SECRET_NAME="aws-credentials"
readonly DEFAULT_AWS_PROFILE="lcp-sandbox"

# Function to create secrets in the cluster from the AWS credential file
function create_secrets_in_cluster_from_aws_credential_file() {
    local aws_credentials_file=${1:-$DEFAULT_AWS_CREDENTIALS_FILE}
    local secret_name=${2:-$DEFAULT_SECRET_NAME}

    kubectl create secret generic "$secret_name" --from-file="$aws_credentials_file"
    pretty_print "\n${BLUE}Secrets Created in Cluster from $aws_credentials_file${NC}\n"
}

# Function to check the expiration time of the AWS token
function check_aws_token_expiration_time() {
    local aws_profile=${1:-$DEFAULT_AWS_PROFILE}
    local aws_token_expiration_time=$(kubectl get secret aws-credentials -o jsonpath='{.data.credentials}' | base64 --decode | aws configure get x_security_token_expires --profile "$aws_profile")
    local current_time=$(date +%s)
    local expiration_time=$(date -d "$aws_token_expiration_time" +%s)
    local remaining_minutes=$(( (expiration_time - current_time) / 60 ))

    if ((remaining_minutes > 0)); then
        pretty_print "\n${BLUE}AWS Token will expire in: $remaining_minutes minutes.${NC}\n"
    else
        pretty_print "\n${BLUE}AWS Token has already expired.${NC}\n"
    fi
}

# view_aws_credentials_from_cluster 
function view_aws_credentials_from_cluster() {
    local secret_name=${2:-$DEFAULT_SECRET_NAME}
    kubectl get secret $secret_name -o jsonpath='{.data.credentials}' | base64 --decode
}

# Example usage
# create_secrets_in_cluster_from_aws_credential_file
# check_aws_token_expiration_time
# create_secrets_in_cluster_from_aws_credential_file "$HOME/.aws/credentials" "aws-credentials"
# check_aws_token_expiration_time "lcp-sandbox"
