#!/usr/bin/env bash

CURRENT_VERSION=$(awk '{print $1}' < /usr/lib/terraria/proc/version)

wget -q https://terraria.org/api/get/dedicated-servers-names -O /tmp/version.json
VERSION=$(jq < /tmp/version.json | grep -Eo "terraria-server-.*.zip" | uniq | sed 's/terraria-server-//; s/.zip//')
rm -f /tmp/version.json

echo "${CURRENT_VERSION}" "${VERSION}" > /usr/lib/terraria/proc/version

