#!/usr/bin/env sh
set -e

# Patch older versions of data if needed
/app/functions/patch.sh

# If config file doesn't exist, make one
if ! [ -f "/data/config.json" ]; then
    if [ -f "/config/config.json" ]; then
        # Migrating old data
        echo "Moving /config/config.json to /data/config.json"
        mv /config/config.json /data/config.json
    else
        # Default to JSON storage
        cp /defaults/config.json /data/config.json
    fi
fi

# If config symlink is broken because user mounted /config, make it
if [ $(readlink -f /config/.config/Red-DiscordBot/config.json) != "/data/config.json" ]; then
    rm -rf /config/.config/Red-DiscordBot
    mkdir -p /config/.config/Red-DiscordBot
    ln -s /data/config.json /config/.config/Red-DiscordBot/config.json
fi

# Prepare and activate venv
echo "Activating Python virtual environment..."
mkdir -p /data/venv
python -m venv --upgrade /data/venv
python -m venv /data/venv
. /data/venv/bin/activate
