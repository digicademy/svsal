#!/bin/bash
set -e

# CI/CD Derivative Generation Script
# Supports both direct work IDs and automatic resolution from changed files

# Configuration from environment variables
EXISTDB_URL="${EXISTDB_URL:-http://localhost:8080}"
EXISTDB_USER="${EXISTDB_USER:-admin}"
EXISTDB_PASSWORD="${EXISTDB_PASSWORD:?EXISTDB_PASSWORD must be set}"
CHANGED_FILES="${CHANGED_FILES:-}"
WORK_IDS="${WORK_IDS:-}"
FORMATS="${FORMATS:-all}"
TIMEOUT="${TIMEOUT:-600}"

echo "=== Salamanca Derivative Generation ==="

# Wait for eXist-db to be ready
echo "Waiting for eXist-db at $EXISTDB_URL..."
timeout 300 bash -c "until curl -sf $EXISTDB_URL >/dev/null 2>&1; do sleep 5; done"
echo "✓ eXist-db is ready"

# Resolve work IDs from changed files if provided
if [ -n "$CHANGED_FILES" ]; then
    echo "Resolving work IDs from changed files..."
    echo "Changed files: $CHANGED_FILES"
    
    RESOLVED_WORKS=$(curl -sf "$EXISTDB_URL/exist/apps/salamanca/webdata-resolve-works.xql" \
        --data-urlencode "files=$CHANGED_FILES" \
        --data-urlencode "format=csv")
    
    if [ -z "$RESOLVED_WORKS" ]; then
        echo "✗ Error: Could not resolve work IDs from changed files"
        exit 1
    fi
    
    WORK_IDS="$RESOLVED_WORKS"
    echo "✓ Resolved work IDs: $WORK_IDS"
fi

# Check if we have work IDs
if [ -z "$WORK_IDS" ]; then
    echo "✗ Error: No work IDs specified (set WORK_IDS or CHANGED_FILES)"
    exit 1
fi

# Generate derivatives
echo "Generating derivatives for: $WORK_IDS"
echo "Formats: $FORMATS"

RESPONSE=$(curl -sf -w "\n%{http_code}" \
    -u "$EXISTDB_USER:$EXISTDB_PASSWORD" \
    "$EXISTDB_URL/exist/apps/salamanca/webdata-admin.xql" \
    --data-urlencode "wid=$WORK_IDS" \
    --data-urlencode "batch=true" \
    --data-urlencode "format=all" \
    --max-time "$TIMEOUT")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "HTTP Status: $HTTP_CODE"

if [ "$HTTP_CODE" = "200" ]; then
    echo "✓ All derivatives generated successfully"
    echo "$BODY" | jq '.' 2>/dev/null || echo "$BODY"
    exit 0
elif [ "$HTTP_CODE" = "207" ]; then
    echo "⚠ Partial success (some works failed)"
    echo "$BODY" | jq '.' 2>/dev/null || echo "$BODY"
    exit 0
else
    echo "✗ Generation failed"
    echo "$BODY"
    exit 1
fi
