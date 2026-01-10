#!/bin/bash

# ####++++----
#
#     Generate Derivatives Script for CI/CD
#
#     This script automates the generation of derivatives (HTML, snippets, RDF, etc.)
#     for TEI works in the School of Salamanca project. It supports both direct work ID
#     specification and intelligent resolution of work IDs from changed TEI files.
#
#     Environment Variables:
#     - EXISTDB_URL: Base URL of eXist-db (default: http://localhost:8080/exist/apps/salamanca)
#     - EXISTDB_USER: Username for authentication (default: admin)
#     - EXISTDB_PASSWORD: Password for authentication (required)
#     - CHANGED_FILES: Comma-separated list of changed TEI file paths
#     - WORK_IDS: Comma-separated list of work IDs (alternative to CHANGED_FILES)
#     - FORMAT: Derivative format to generate (default: all)
#
#     Example Usage:
#     CHANGED_FILES="works/W0013.xml,works/W0066_Vol_02.xml" \
#     EXISTDB_PASSWORD="secret" \
#     ./generate-derivatives.sh
#
# ----++++####

set -e  # Exit on error
set -u  # Exit on undefined variable
set -o pipefail  # Exit on pipe failure

# Configuration from environment variables with defaults
EXISTDB_URL="${EXISTDB_URL:-http://localhost:8080/exist/apps/salamanca}"
EXISTDB_USER="${EXISTDB_USER:-admin}"
EXISTDB_PASSWORD="${EXISTDB_PASSWORD:?Error: EXISTDB_PASSWORD environment variable is required}"
CHANGED_FILES="${CHANGED_FILES:-}"
WORK_IDS="${WORK_IDS:-}"
FORMAT="${FORMAT:-all}"
TIMEOUT="${TIMEOUT:-300}"

# Color output for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

# Wait for eXist-db to be ready
wait_for_existdb() {
    log_info "Waiting for eXist-db at $EXISTDB_URL..."

    local elapsed=0
    local interval=5

    while [ $elapsed -lt "$TIMEOUT" ]; do
        if curl -sf "$EXISTDB_URL" > /dev/null 2>&1; then
            log_info "eXist-db is ready"
            return 0
        fi

        sleep $interval
        elapsed=$((elapsed + interval))

        if [ $((elapsed % 30)) -eq 0 ]; then
            log_info "Still waiting... ($elapsed/${TIMEOUT}s elapsed)"
        fi
    done

    log_error "Timeout waiting for eXist-db after ${TIMEOUT}s"
    return 1
}

# Resolve work IDs from changed files using the work resolver endpoint
resolve_work_ids() {
    local files="$1"

    log_info "Resolving work IDs from changed files: $files"

    # URL encode the files parameter
    local encoded_files=$(echo "$files" | sed 's/ /%20/g')

    # Call the work resolver endpoint
    local resolver_url="$EXISTDB_URL/webdata-resolve-works.xql?files=$encoded_files&format=csv"

    log_info "Calling resolver endpoint: $resolver_url"

    local resolved_works
    resolved_works=$(curl -sf -u "$EXISTDB_USER:$EXISTDB_PASSWORD" "$resolver_url" 2>&1)
    local curl_exit=$?

    if [ $curl_exit -ne 0 ]; then
        log_error "Failed to resolve work IDs from changed files"
        log_error "Curl exit code: $curl_exit"
        log_error "Response: $resolved_works"
        return 1
    fi

    if [ -z "$resolved_works" ]; then
        log_error "Work resolver returned empty result"
        return 1
    fi

    echo "$resolved_works"
    return 0
}

# Generate derivatives for a single work
generate_work() {
    local work_id="$1"

    log_info "Generating derivatives for work: $work_id (format: $FORMAT)"

    local admin_url="$EXISTDB_URL/webdata-admin.xql?rid=$work_id&format=$FORMAT"

    # Generate derivatives
    local response
    local http_code

    response=$(curl -w "\n%{http_code}" -s -u "$EXISTDB_USER:$EXISTDB_PASSWORD" "$admin_url" 2>&1)
    http_code=$(echo "$response" | tail -n1)
    local response_body=$(echo "$response" | head -n -1)

    if [ "$http_code" = "200" ]; then
        log_info "Successfully generated derivatives for $work_id"
        return 0
    else
        log_error "Failed to generate derivatives for $work_id (HTTP $http_code)"
        log_error "Response: $response_body"
        return 1
    fi
}

# Main execution
main() {
    log_info "=== Salamanca Derivative Generation Script ==="
    log_info "eXist-db URL: $EXISTDB_URL"
    log_info "Format: $FORMAT"

    # Wait for eXist-db to be ready
    if ! wait_for_existdb; then
        exit 1
    fi

    # Determine work IDs to process
    local work_ids_to_process=""

    if [ -n "$CHANGED_FILES" ]; then
        log_info "Mode: Resolve work IDs from changed files"
        work_ids_to_process=$(resolve_work_ids "$CHANGED_FILES")

        if [ $? -ne 0 ] || [ -z "$work_ids_to_process" ]; then
            log_error "Failed to resolve work IDs from changed files"
            exit 1
        fi

        log_info "Resolved work IDs: $work_ids_to_process"

    elif [ -n "$WORK_IDS" ]; then
        log_info "Mode: Using directly specified work IDs"
        work_ids_to_process="$WORK_IDS"
        log_info "Work IDs: $work_ids_to_process"

    else
        log_error "No work IDs specified. Set WORK_IDS or CHANGED_FILES environment variable."
        exit 1
    fi

    # Generate derivatives for each work
    log_info "Starting derivative generation..."

    local success_count=0
    local failure_count=0
    local total_count=0

    # Convert comma-separated list to array
    IFS=',' read -ra work_array <<< "$work_ids_to_process"

    for work_id in "${work_array[@]}"; do
        # Trim whitespace
        work_id=$(echo "$work_id" | xargs)

        if [ -n "$work_id" ]; then
            total_count=$((total_count + 1))

            if generate_work "$work_id"; then
                success_count=$((success_count + 1))
            else
                failure_count=$((failure_count + 1))
            fi
        fi
    done

    # Summary
    log_info "=== Generation Summary ==="
    log_info "Total works processed: $total_count"
    log_info "Successful: $success_count"

    if [ $failure_count -gt 0 ]; then
        log_warn "Failed: $failure_count"
        exit 1
    fi

    log_info "All derivatives generated successfully!"
    exit 0
}

# Run main function
main "$@"
