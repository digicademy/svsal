#!/bin/sh

# This script is used to generate the XML pipe for SphinxSearch.
# It is called by the indexer, prepares and concatenates the XML files,
# prefixes the schema definition and outputs the whole XML to stdout.
# Preparation means removing the XML prolog and namespace declaration
# from the XML files.

echo '<?xml version="1.0" encoding="utf-8" standalone="yes"?>'
echo '<sphinx:docset>'

# schema file probably has no prolog, but strip it if present:
sed -e 's|<?xml[^>]*?>||g' /etc/sphinx/sal-schema.xml

# busybox's cat does not handle `-s` or globstar wildcards, so this does not work:
# cat -s /var/data/caddy/site/data/**/snippets/*.xml
find "${SALAMANCA_DATA}" -type f -path '*/snippets/*.snippet.xml' -exec cat {} +

# find "${SALAMANCA_DATA}" -type f -name '*.snippet.xml' -exec \
#     sed -e 's|<?xml[^>]*?>||g' \
#         -e 's| xmlns:sphinx="https://www.salamanca.school/xquery/sphinx"||g' \
#         {} +

echo '</sphinx:docset>'
