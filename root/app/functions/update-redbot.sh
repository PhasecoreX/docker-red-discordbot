#!/usr/bin/env sh
set -e

# Make sure we are in the venv
[ -n "${VIRTUAL_ENV}" ]

# Determine if we need SetupTools Extras
if [ -z "${STORAGE_TYPE}" ]; then
    STORAGE_TYPE=$(jq -r .docker.STORAGE_TYPE /data/config.json | tr '[A-Z]' '[a-z]')
fi
SETUPTOOLS_EXTRAS=""
if [ "${STORAGE_TYPE}" != "json" ]; then
    SETUPTOOLS_EXTRAS="[${STORAGE_TYPE}]"
fi

# Update redbot
REDBOT_PACKAGE_NAME=Red-DiscordBot${SETUPTOOLS_EXTRAS}${REDBOT_VERSION}
echo "Updating ${REDBOT_PACKAGE_NAME}..."
python -m pip install --upgrade --no-cache-dir pip setuptools wheel
python -m pip install --upgrade --no-cache-dir ${REDBOT_PACKAGE_NAME}
