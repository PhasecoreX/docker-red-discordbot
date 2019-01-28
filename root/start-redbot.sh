#!/usr/bin/env sh
set -e

mkdir -p /data/venv

python3 -m venv /data/venv

source /data/venv/bin/activate

pip3 install -U Red-DiscordBot

exec redbot docker
