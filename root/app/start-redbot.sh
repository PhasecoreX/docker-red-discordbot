#!/usr/bin/env sh
set -ef

# Setup environment
. /app/functions/setup-env.sh

# Start bot loop
. /app/functions/main-loop.sh
