#!/bin/sh

find ${SALAMANCA_DATA} -type f -name "*.snippet.xml" -exec sed -i 's| xmlns:sphinx="https://www.salamanca.school/xquery/sphinx"||g' {} +
