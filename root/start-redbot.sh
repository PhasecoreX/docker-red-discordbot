#!/usr/bin/env sh
set -e

# discord.py doesn't update properly to 1.0.1, so we are forced to delete the venv
if [ ! -f "/data/venv/pcxupdates.txt" ]; then
    rm -rf /data/venv
    mkdir -p /data/venv
    echo "1" > "/data/venv/pcxupdates.txt"
fi

mkdir -p /data/venv
python -m venv --upgrade /data/venv
python -m venv /data/venv
source /data/venv/bin/activate

python -m pip install --upgrade --no-cache-dir pip
python -m pip install --upgrade --no-cache-dir Red-DiscordBot

exec redbot docker
