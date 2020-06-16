#!/usr/bin/env sh
set -euf

# Setup environment
. /app/functions/setup-env.sh

# Start bot loop
. /app/functions/main-loop.sh
