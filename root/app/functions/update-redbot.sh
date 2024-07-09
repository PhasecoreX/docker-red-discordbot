#!/usr/bin/env sh
set -euf

stringContain() { case $2 in *$1* ) return 0;; *) return 1;; esac ;}

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

if stringContain "pylav" "${PCX_DISCORDBOT_TAG}"; then
    if [ -z "${PYLAV__DOCKER_DEV_SKIP_INSTALL:-}" ]; then
        git config --global --add safe.directory '*'
        python /app/functions/pylav_setup.py
    fi
fi

if [ -n "${CUSTOM_REDBOT_PACKAGE:-}" ]; then
    echo "WARNING: You have specified a custom Red-DiscordBot Pip install. Little to no support will be given for this setup."
    echo "Updating Red-DiscordBot with \"${CUSTOM_REDBOT_PACKAGE}\"..."
    python -m pip install --upgrade --upgrade-strategy eager --no-cache-dir wheel "${CUSTOM_REDBOT_PACKAGE}"
    echo "${CUSTOM_REDBOT_PACKAGE}" >"/data/venv/.redbotversion"
else
    # Update redbot
    REDBOT_PACKAGE_NAME="Red-DiscordBot${SETUPTOOLS_EXTRAS}${REDBOT_VERSION:-}"
    UPGRADE_STRATEGY=""
    if [ ! -f "/data/venv/.redbotversion" ] || [ "$(cat "/data/venv/.redbotversion")" != "${REDBOT_PACKAGE_NAME}" ]; then
        UPGRADE_STRATEGY="--upgrade-strategy eager"
    fi
    echo "Updating ${REDBOT_PACKAGE_NAME}..."
    # shellcheck disable=SC2086
    python -m pip install --upgrade ${UPGRADE_STRATEGY} --no-cache-dir wheel "${REDBOT_PACKAGE_NAME}"
    echo "${REDBOT_PACKAGE_NAME}" >"/data/venv/.redbotversion"
fi
