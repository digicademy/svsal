#!/bin/sh

# This prepares the XML snippet files by removing the
# XML prolog and Sphinx namespace declaration.

find "${SALAMANCA_DATA}" -type f -name '*.snippet.xml' -exec \
    sed -i 's|<?xml[^>]*?>||g' \
        -i 's| xmlns:sphinx="https://www.salamanca.school/xquery/sphinx"||g' \
        {} +

# This was the previous approach, which only removed the Sphinx namespace declaration.
#
# find ${SALAMANCA_DATA} -type f -name "*.snippet.xml" -exec \
#     sed -i 's| xmlns:sphinx="https://www.salamanca.school/xquery/sphinx"||g' {} +
