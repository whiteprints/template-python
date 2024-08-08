#!/bin/sh

set -e

wget https://raw.githubusercontent.com/spdx/license-list-data/main/json/licenses.json --quiet -O licenses.json
jq '.licenses[] | select(.licenseId | startswith("CC-") or startswith("CC0-")) | .licenseId' licenses.json | paste -sd ',' - > resource_licenses.txt
rm licenses.json
