#!/usr/bin/env sh
set -euf

# Python 3.8, remove mongo dependencies
if ! [ -f "/data/venv/.pcxversion" ]; then
    rm -rf /data/venv
    mkdir -p /data/venv
    echo "2" >"/data/venv/.pcxversion"
fi

# Python 3.9, remove 3.8 dependencies
if [ "$(cat "/data/venv/.pcxversion")" = "1" ]; then
    rm -rf /data/venv
    mkdir -p /data/venv
    echo "2" >"/data/venv/.pcxversion"
fi
