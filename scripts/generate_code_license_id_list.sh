#!/bin/sh

set -e

wget https://raw.githubusercontent.com/spdx/license-list-data/main/json/licenses.json --quiet -O licenses.json
jq '.licenses[] | select(.isOsiApproved) | .licenseId' licenses.json | paste -sd ',' - > code_licenses.txt
rm licenses.json
