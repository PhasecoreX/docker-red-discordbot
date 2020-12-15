#!/usr/bin/env sh
set -euf

# Make sure we are in the venv
[ -n "${VIRTUAL_ENV:-}" ]

# Determine if we need SetupTools Extras
if [ -z "${STORAGE_TYPE:-}" ]; then
    STORAGE_TYPE=$(jq -r .docker.STORAGE_TYPE /data/config.json | tr '[:upper:]' '[:lower:]')
fi
SETUPTOOLS_EXTRAS=""
if [ "${STORAGE_TYPE}" != "json" ]; then
    SETUPTOOLS_EXTRAS="[${STORAGE_TYPE}]"
fi

if [ -n "${CUSTOM_REDBOT_PACKAGE:-}" ]; then
    echo "WARNING: You have specified a custom Red-DiscordBot Pip install. Little to no support will be given for this setup."
    echo "Updating Red-DiscordBot with \"${CUSTOM_REDBOT_PACKAGE}\"..."
    python -m pip install --upgrade --no-cache-dir pip
    python -m pip install --upgrade --no-cache-dir setuptools wheel
    python -m pip install --upgrade --no-cache-dir "${CUSTOM_REDBOT_PACKAGE}"
else
    # Update redbot
    REDBOT_PACKAGE_NAME="Red-DiscordBot${SETUPTOOLS_EXTRAS}${REDBOT_VERSION:-}"
    echo "Updating ${REDBOT_PACKAGE_NAME}..."
    python -m pip install --upgrade --no-cache-dir pip
    python -m pip install --upgrade --no-cache-dir setuptools wheel
    python -m pip install --upgrade --no-cache-dir "${REDBOT_PACKAGE_NAME}"
fi
