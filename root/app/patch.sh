#!/usr/bin/env sh
set -e

# discord.py doesn't update properly to 1.0.1, so we are forced to delete the venv
if ! [ -f "/data/venv/pcxupdates.txt" ]
then
    rm -rf /data/venv
    mkdir -p /data/venv
    echo "1" > "/data/venv/pcxupdates.txt"
fi

# https://github.com/Cog-Creators/Red-DiscordBot/issues/2714 was fixed, so we can delete our workaround
if [ "x$(cat /data/venv/pcxupdates.txt)" = "x1" ]
then
    rm -rf /data/.tmp
    echo "2" > "/data/venv/pcxupdates.txt"
fi
