#!/usr/bin/env sh
set -euf

# Remove old python venv if detected
PYVERSION=$(realpath "$(command -v python)" | grep -o '[^/]*$')
if [ ! -f "/data/venv/.pyversion" ] || [ "$(cat "/data/venv/.pyversion")" != "${PYVERSION}" ]; then
    rm -rf /data/venv
    mkdir -p /data/venv
    echo "${PYVERSION}" >"/data/venv/.pyversion"
fi

# If config file doesn't exist, make one
if ! [ -f "/data/config.json" ]; then
    if [ -f "${HOME}/config.json" ]; then
        # Migrating old data
        echo "Moving ${HOME}/config.json to /data/config.json"
        mv "${HOME}/config.json" /data/config.json
    else
        # Default to JSON storage
        cp /defaults/config.json /data/config.json
    fi
fi

# If config symlink is broken because user mounted the home directory (/config or /root), make it
if [ "$(readlink -f "${HOME}/.config/Red-DiscordBot/config.json")" != "/data/config.json" ]; then
    rm -rf "${HOME}/.config/Red-DiscordBot/config.json"
    mkdir -p "${HOME}/.config/Red-DiscordBot"
    ln -s /data/config.json "${HOME}/.config/Red-DiscordBot/config.json"
fi

# Prepare and activate venv
echo "Activating Python virtual environment..."
mkdir -p /data/venv
python -m venv --upgrade --upgrade-deps /data/venv
python -m venv /data/venv
. /data/venv/bin/activate
