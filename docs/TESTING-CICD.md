# Testing CI/CD Derivative Generation

This document provides testing instructions for the CI/CD derivative generation functionality.

## Unit Tests for Work Resolution

### Test 1: Extract Work ID from File Path

```xquery
import module namespace resolver = "https://www.salamanca.school/xquery/resolver" 
    at "modules/work-resolver.xqm";

(: Test various file path patterns :)
let $tests := (
    map { "input": "works/W0066_Vol_02.xml", "expected": "W0066_Vol_02" },
    map { "input": "works/W0013.xml", "expected": "W0013" },
    map { "input": "/db/apps/salamanca-tei/works/W0001.xml", "expected": "W0001" },
    map { "input": "lemmata/L0001.xml", "expected": () }
)
return
    for $test in $tests
    let $result := resolver:extract-work-id($test?input)
    let $passed := $result = $test?expected
    return
        if ($passed) then
            "✓ PASS: " || $test?input || " → " || $result
        else
            "✗ FAIL: " || $test?input || " expected " || $test?expected || " but got " || $result
```

### Test 2: Resolve Multiple Files

```xquery
import module namespace resolver = "https://www.salamanca.school/xquery/resolver" 
    at "modules/work-resolver.xqm";

(: Test resolving multiple file paths :)
let $files := ("works/W0066_Vol_02.xml", "works/W0013.xml", "works/W0001.xml")
let $resolved := resolver:resolve-work-ids($files)
return
    map {
        "input": array { $files },
        "resolved": array { $resolved },
        "count": count($resolved)
    }
```

## Integration Tests

### Test 1: Work Resolution Endpoint (JSON)

```bash
curl "http://localhost:8080/exist/apps/salamanca/webdata-resolve-works.xql" \
  --data-urlencode "files=works/W0066_Vol_02.xml,works/W0013.xml" \
  --data-urlencode "format=json"
```

Expected Response:
```json
{
  "works": ["W0066", "W0013"],
  "resolved": {
    "works/W0066_Vol_02.xml": ["W0066"],
    "works/W0013.xml": ["W0013"]
  },
  "count": 2
}
```

### Test 2: Work Resolution Endpoint (CSV)

```bash
curl "http://localhost:8080/exist/apps/salamanca/webdata-resolve-works.xql" \
  --data-urlencode "files=works/W0066_Vol_02.xml,works/W0013.xml" \
  --data-urlencode "format=csv"
```

Expected Response:
```
W0066,W0013
```

### Test 3: Batch Generation (Single Work)

```bash
curl -u "admin:password" \
  "http://localhost:8080/exist/apps/salamanca/webdata-admin.xql" \
  --data-urlencode "wid=W0013" \
  --data-urlencode "batch=true" \
  --data-urlencode "format=index"
```

Expected Response:
```json
{
  "results": [
    {
      "work": "W0013",
      "status": "success",
      "format": "index"
    }
  ],
  "total": 1,
  "successful": 1,
  "failed": 0,
  "runtime": "0.23 seconds"
}
```

### Test 4: Batch Generation (Multiple Works)

```bash
curl -u "admin:password" \
  "http://localhost:8080/exist/apps/salamanca/webdata-admin.xql" \
  --data-urlencode "wid=W0013,W0066" \
  --data-urlencode "batch=true" \
  --data-urlencode "format=all"
```

Expected Response (HTTP 200 or 207):
```json
{
  "results": [
    {
      "work": "W0013",
      "status": "success",
      "format": "all"
    },
    {
      "work": "W0066",
      "status": "success",
      "format": "all"
    }
  ],
  "total": 2,
  "successful": 2,
  "failed": 0,
  "runtime": "5.67 minutes"
}
```

### Test 5: Batch Endpoint (Multiple Formats)

```bash
curl -u "admin:password" \
  "http://localhost:8080/exist/apps/salamanca/webdata-batch.xql" \
  --data-urlencode "works=W0013,W0066" \
  --data-urlencode "formats=index,html,details"
```

Expected Response:
```json
{
  "results": [
    {
      "work": "W0013",
      "formats": [
        {"format": "index", "status": "success"},
        {"format": "html", "status": "success"},
        {"format": "details", "status": "success"}
      ]
    },
    {
      "work": "W0066",
      "formats": [
        {"format": "index", "status": "success"},
        {"format": "html", "status": "success"},
        {"format": "details", "status": "success"}
      ]
    }
  ],
  "summary": {
    "totalWorks": 2,
    "totalOperations": 6,
    "successful": 6,
    "failed": 0,
    "formats": ["index", "html", "details"],
    "runtime": "3.21 minutes"
  },
  "timestamp": "2024-01-10T16:00:00Z"
}
```

## End-to-End Test: CI/CD Script

### Setup

```bash
# Start services
cd docker
docker-compose -f docker-compose.cicd.yml up -d

# Wait for eXist-db
timeout 300 bash -c "until curl -sf http://localhost:8080 >/dev/null 2>&1; do sleep 5; done"

# Mount sample TEI files (if available)
docker cp /path/to/tei-files/. existdb-cicd:/exist/apps/salamanca-tei/
```

### Test: Changed Files Resolution

```bash
export EXISTDB_PASSWORD="admin"
export CHANGED_FILES="works/W0066_Vol_02.xml,works/W0013.xml"
export EXISTDB_URL="http://localhost:8080"

cd scripts
./generate-derivatives.sh
```

Expected Output:
```
=== Salamanca Derivative Generation ===
Waiting for eXist-db at http://localhost:8080...
✓ eXist-db is ready
Resolving work IDs from changed files...
Changed files: works/W0066_Vol_02.xml,works/W0013.xml
✓ Resolved work IDs: W0066,W0013
Generating derivatives for: W0066,W0013
Formats: all
HTTP Status: 200
✓ All derivatives generated successfully
{
  "results": [...],
  "total": 2,
  "successful": 2,
  "failed": 0,
  "runtime": "..."
}
```

### Test: Direct Work IDs

```bash
export WORK_IDS="W0013,W0066"
unset CHANGED_FILES

./generate-derivatives.sh
```

Expected Output:
```
=== Salamanca Derivative Generation ===
Waiting for eXist-db at http://localhost:8080...
✓ eXist-db is ready
Generating derivatives for: W0013,W0066
Formats: all
HTTP Status: 200
✓ All derivatives generated successfully
...
```

### Test: Error Handling

```bash
# Test with invalid work ID
export WORK_IDS="W9999"

./generate-derivatives.sh
```

Expected Output (with error):
```
=== Salamanca Derivative Generation ===
Waiting for eXist-db at http://localhost:8080...
✓ eXist-db is ready
Generating derivatives for: W9999
Formats: all
HTTP Status: 500
✗ Generation failed
{
  "results": [
    {
      "work": "W9999",
      "status": "error",
      "message": "..."
    }
  ],
  "total": 1,
  "successful": 0,
  "failed": 1
}
```

## Performance Tests

### Test: Large Batch

```bash
# Generate all works
curl -u "admin:password" \
  "http://localhost:8080/exist/apps/salamanca/webdata-admin.xql" \
  --data-urlencode "wid=all" \
  --data-urlencode "batch=true" \
  --data-urlencode "format=index"
```

Monitor:
- Memory usage in eXist-db container
- Response time
- Success/failure ratio

### Test: Concurrent Requests

```bash
# Run multiple requests in parallel
for i in {1..5}; do
  curl -u "admin:password" \
    "http://localhost:8080/exist/apps/salamanca/webdata-admin.xql" \
    --data-urlencode "wid=W001$i" \
    --data-urlencode "batch=true" \
    --data-urlencode "format=html" &
done
wait
```

## Cleanup

```bash
cd docker
docker-compose -f docker-compose.cicd.yml down -v
```

## Test Checklist

- [ ] Work ID extraction from file paths
- [ ] XInclude parent work detection
- [ ] Comma-separated work ID parsing
- [ ] JSON output format in batch mode
- [ ] CSV output format in work resolution
- [ ] HTTP status codes (200, 207, 500)
- [ ] Error handling per work
- [ ] Shell script work resolution
- [ ] Shell script direct work IDs
- [ ] Shell script error handling
- [ ] Docker Compose service startup
- [ ] TEI file mounting
- [ ] Full end-to-end workflow
- [ ] Performance with large batches
- [ ] Concurrent request handling
