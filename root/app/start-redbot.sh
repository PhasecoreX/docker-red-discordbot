#!/usr/bin/env sh
set -euf

# Perform mount check
/app/functions/check-mount.sh

# Setup environment
. /app/functions/setup-env.sh

# Start bot loop
. /app/functions/main-loop.sh
