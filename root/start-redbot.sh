#!/usr/bin/env sh
set -e
export PCX_DISCORDBOT=true

mkdir -p /data/venv
python -m venv --upgrade /data/venv
python -m venv /data/venv
source /data/venv/bin/activate

pip install -U pip
pip install -U Red-DiscordBot

exec redbot docker
