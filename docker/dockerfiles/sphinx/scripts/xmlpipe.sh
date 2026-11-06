#!/bin/sh

# This script is used to generate the XML pipe for SphinxSearch.
# It is called by the indexer, prepares and concatenates the XML files,
# prefixes the schema definition and outputs the whole XML to stdout.
# Preparation means removing the namespace declaration from the XML files.

# find /var/data/existdb/data/export -type f -name "*.snippet.xml" -exec sed -i 's| xmlns:sphinx="https://www.salamanca.school/xquery/sphinx"||g' {} +  >/dev/null 2>&1
find ${SALAMANCA_DATA} -type f -name "*.snippet.xml" -exec sed -i 's| xmlns:sphinx="https://www.salamanca.school/xquery/sphinx"||g' {} +  >/dev/null

echo '<?xml version="1.0" encoding="utf-8" standalone="yes"?>'
echo '<sphinx:docset>'

# schema file probably has no prolog, but strip it if present:
sed -e 's|<?xml[^>]*?>||g' /etc/sphinx/sal-schema.xml
# cat -s /var/data/caddy/site/data/**/snippets/*.xml

find "${SALAMANCA_DATA}" -type f -name '*.snippet.xml' -exec \
    sed -e 's|<?xml[^>]*?>||g' \
        -e 's| xmlns:sphinx="https://www.salamanca.school/xquery/sphinx"||g' \
        {} +

echo '</sphinx:docset>'
