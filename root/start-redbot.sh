#!/usr/bin/env sh
set -e

mkdir -p /data/venv

python3 -m venv /data/venv

source /data/venv/bin/activate

set +e

pip3 install -U --process-dependency-links --no-cache-dir Red-DiscordBot[voice]

set -e

exec redbot docker
