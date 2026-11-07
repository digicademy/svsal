#!/bin/sh
set -eu

STAMP=/var/lib/sphinx/.snippet-sed-stamp
SEDF=/etc/sphinx/prepare.sed
START=$(mktemp)
touch "$START"

if [ -e "$STAMP" ]; then
    find "${SALAMANCA_DATA}" -type f -name '*.snippet.xml' \
        -newer "$STAMP" \
        -exec sed -i -f "$SEDF" {} +
else
    echo "   (first run: no stamp, processing all files)"
    find "${SALAMANCA_DATA}" -type f -name '*.snippet.xml' \
        -exec sed -i -f "$SEDF" {} +
fi

mv "$START" "$STAMP"
