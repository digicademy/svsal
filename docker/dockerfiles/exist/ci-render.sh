#!/usr/bin/env bash
set -euo pipefail

# CI/CD helper: import TEI source files into eXist-db and trigger webdata generation
#
# Usage: ci-render.sh <exist-url> <admin-password> <file1.xml> [file2.xml ...]
#
# The script:
# 1. Uploads each TEI XML file into the eXist-db database
# 2. Triggers node indexing (must come first)
# 3. Triggers all other webdata formats
# 4. Exports generated artifacts

EXIST_URL="${1:?Usage: ci-render.sh <exist-url> <admin-password> <file1.xml> ...}"
ADMIN_PW="${2:?Missing admin password}"
shift 2

APP_BASE="${EXIST_URL}/exist/apps/salamanca"
REST_BASE="${EXIST_URL}/exist/rest/db/apps"
TIMEOUT=7200  # 2 hours max per format

# Wait for eXist-db to be ready
echo "⏳ Waiting for eXist-db..."
for i in $(seq 1 60); do
  if curl -sf "${EXIST_URL}/exist/status" > /dev/null 2>&1; then
    echo "✅ eXist-db is ready."
    break
  fi
  if [ "$i" -eq 60 ]; then
    echo "❌ eXist-db failed to start within 5 minutes."
    exit 1
  fi
  sleep 5
done

# Collect work IDs from the file names (e.g., W0100_Vol01.xml -> W0100)
declare -A WORK_IDS

for xml_file in "$@"; do
  filename=$(basename "$xml_file")
  # Extract work ID (e.g., W0100 from W0100_Vol01.xml)
  wid=$(echo "$filename" | grep -oP '^W\d+' || true)

  if [ -z "$wid" ]; then
    echo "⚠️  Skipping $filename — cannot extract work ID"
    continue
  fi

  WORK_IDS["$wid"]=1

  echo "📤 Uploading $filename to eXist-db..."
  curl -sf -X PUT \
    -u "admin:${ADMIN_PW}" \
    -H "Content-Type: application/xml" \
    --data-binary "@${xml_file}" \
    "${REST_BASE}/salamanca-tei/works/${filename}"

  echo "   ✅ Uploaded."
done

# For each unique work ID, trigger rendering in the correct order
FORMATS_ORDERED="index crumbtrails html details snippets nlp stats routing"

for wid in "${!WORK_IDS[@]}"; do
  echo ""
  echo "🔨 Processing work ${wid}..."

  for fmt in $FORMATS_ORDERED; do
    echo "   ⏳ Generating ${fmt}..."
    HTTP_CODE=$(curl -sf -o /dev/null -w "%{http_code}" \
      -u "admin:${ADMIN_PW}" \
      --max-time $TIMEOUT \
      "${APP_BASE}/webdata-admin.xql?rid=${wid}&format=${fmt}")

    if [ "$HTTP_CODE" -eq 200 ]; then
      echo "   ✅ ${fmt} done."
    else
      echo "   ❌ ${fmt} failed (HTTP ${HTTP_CODE})."
      exit 1
    fi
  done
done

echo ""
echo "🎉 All rendering complete."