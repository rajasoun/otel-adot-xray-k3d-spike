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

# delete_aws_credentials_from_cluster deletes the secret from the cluster
function delete_aws_credentials_from_cluster() {
    local secret_name=${1:-$DEFAULT_SECRET_NAME}
    check_secret_exist_in_cluster $secret_name || return 1
    kubectl delete secret $secret_name
}

# Function to check the expiration time of the AWS token
function check_aws_token_expiration_time() {
    local aws_profile=${1:-$DEFAULT_AWS_PROFILE}
    local secret_name=${2:-$DEFAULT_SECRET_NAME}
    pretty_print "\n\tAWS Profile: $aws_profile\n"
    check_secret_exist_in_cluster $secret_name || return 1

    local aws_token_expiration_time=$(kubectl get secret $secret_name -o jsonpath='{.data.credentials}' | base64 --decode | aws configure get x_security_token_expires --profile "$aws_profile")
    local current_time=$(date +%s)
    local expiration_time=$(date -d "$aws_token_expiration_time" +%s)
    local remaining_minutes=$(( (expiration_time - current_time) / 60 ))

    if ((remaining_minutes > 0)); then
        pretty_print "\n\t${BLUE}AWS Token in cluster will expire in: $remaining_minutes minutes.${NC}\n"
    else
        pretty_print "\n\t${BLUE}AWS Token in cluster has already expired.${NC}\n"
    fi
}

# Function to check the expiration time of the AWS token in the local machine
function check_local_aws_token_expiration_time() {
    local aws_profile=${1:-$DEFAULT_AWS_PROFILE}
    local secret_name=${2:-$DEFAULT_SECRET_NAME}
    pretty_print "\n\tAWS Profile: $aws_profile"
    check_aws_profile_exists "$aws_profile" || return 1

    local aws_token_expiration_time=$(aws configure get x_security_token_expires --profile "$aws_profile")
    local current_time=$(date +%s)
    local expiration_time=$(date -d "$aws_token_expiration_time" +%s)
    local remaining_minutes=$(( (expiration_time - current_time) / 60 ))

    if ((remaining_minutes > 0)); then
        pretty_print "\n\t${BLUE}AWS Token will expire in: $remaining_minutes minutes.${NC}\n"
    else
        pretty_print "\n\t${BLUE}AWS Token has already expired.${NC}\n"
        pretty_print "\n\t${RED}Execute -> duo-sso${NC}\n"
    fi
}

# view_aws_credentials_from_cluster vews the secret from the cluster
function view_aws_credentials_from_cluster() {
    local secret_name=${1:-$DEFAULT_SECRET_NAME}
    check_secret_exist_in_cluster $secret_name || return 1
    kubectl get secret $secret_name -o jsonpath='{.data.credentials}' | base64 --decode
}

# check_secret checks if the secret exists in the cluster
function check_secret_exist_in_cluster() {
    local secret_name=${1:-$DEFAULT_SECRET_NAME}
    local secret_output

    # Run kubectl command to get the secret
    secret_output=$(kubectl get secret "$secret_name" 2>/dev/null)

    # Check if the secret exists
    if [[ -n "$secret_output" ]]; then
        pretty_print "\t${GREEN}Secret '$secret_name' exists.\n${NC}"
        return 0
    else
        pretty_print "\t${RED}Secret '$secret_name' does not exist.\n${NC}"
        return 1
    fi
}

# Function to check if the AWS profile exists
function check_aws_profile_exists() {
    local aws_profile=${1:-$DEFAULT_AWS_PROFILE}
    if ! aws configure get aws_access_key_id --profile "$aws_profile" >/dev/null 2>&1; then
        pretty_print "\n\t${RED}AWS Profile '$aws_profile' does not exist.${NC}"
        return 1
    else 
        pretty_print "\n\t${GREEN}AWS Profile '$aws_profile' exists.${NC}"
        return 0
    fi
}


# Example usage
# create_secrets_in_cluster_from_aws_credential_file
# check_aws_token_expiration_time
# create_secrets_in_cluster_from_aws_credential_file "$HOME/.aws/credentials" "aws-credentials"
# check_aws_token_expiration_time "lcp-sandbox"
