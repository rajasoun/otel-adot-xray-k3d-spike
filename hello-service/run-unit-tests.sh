#!/usr/bin/env bash

# Define constants for formatting
NC=$'\e[0m' # No Color
RED=$'\e[31m'
GREEN=$'\e[32m'
BLUE=$'\e[34m'
ORANGE=$'\x1B[33m'
YELLOW='\033[1;33m'
BOLD=$'\033[1m'
UNDERLINE=$'\033[4m'

# Define constant for coverage report directory
REPORTS_DIR=".reports"

# Function : Run unit tests and generate coverage report
function run_unit_tests() {
    echo "${BLUE}Running Unit Tests${NC}"
    #go test -v -tags integration ./... --coverprofile "$REPORTS_DIR/outfile"
    go test -v  ./... --coverprofile "$REPORTS_DIR/outfile"
    go tool cover -html="$REPORTS_DIR/outfile" -o "$REPORTS_DIR/cover.html"
}

# Function: Open coverage report in default browser
function open_coverage_report() {
    echo "${BLUE}Opening coverage report${NC}"
    open "$REPORTS_DIR/cover.html"
}

# Function: Create directory for coverage report if it doesn't exist
function create_coverage_report_dir() {
    if [ ! -d "$REPORTS_DIR" ]; then
        mkdir -p "$REPORTS_DIR"
    fi
}

# Function: Define the check_coverage_threshold function
function check_coverage_threshold() {
    echo -e "\nQuality Gate: Test Coverage Check"
    totalCoverage=$(go tool cover -func="$REPORTS_DIR/outfile" | grep total | grep -Eo '[0-9]+\.[0-9]+')
    echo -e "\n${ORANGE}Current test coverage:${NC} ${BLUE}$totalCoverage %${NC}"
    echo ""
}

# Function: main 
function main() {
    create_coverage_report_dir
    run_unit_tests
    check_coverage_threshold
    open_coverage_report
}

main "$@"
