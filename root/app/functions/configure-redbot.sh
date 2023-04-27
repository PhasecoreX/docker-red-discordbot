#!/usr/bin/env sh
set -euf

# Make sure we are in the venv
[ -n "${VIRTUAL_ENV:-}" ]

# Gather prefixes if supplied
PREFIXES=""
if [ -n "${PREFIX5:-}" ]; then
    PREFIXES="--prefix ${PREFIX5} ${PREFIXES}"
    unset PREFIX5
fi
if [ -n "${PREFIX4:-}" ]; then
    PREFIXES="--prefix ${PREFIX4} ${PREFIXES}"
    unset PREFIX4
fi
if [ -n "${PREFIX3:-}" ]; then
    PREFIXES="--prefix ${PREFIX3} ${PREFIXES}"
    unset PREFIX3
fi
if [ -n "${PREFIX2:-}" ]; then
    PREFIXES="--prefix ${PREFIX2} ${PREFIXES}"
    unset PREFIX2
fi
if [ -n "${PREFIX:-}" ]; then
    PREFIXES="--prefix ${PREFIX} ${PREFIXES}"
    unset PREFIX
fi

# Set configurations
if [ -n "${OWNER:-}" ]; then
    echo "Setting bot owner..."
    python -O -m redbot docker --edit --no-prompt --owner "${OWNER}"
    unset OWNER
fi

if [ -n "${TOKEN:-}" ]; then
    echo "Setting bot token..."
    python -O -m redbot docker --edit --no-prompt --token "${TOKEN}"
    unset TOKEN
fi

if [ -n "${PREFIXES}" ]; then
    echo "Setting bot prefix(es)..."
    # shellcheck disable=SC2086
    python -O -m redbot docker --edit --no-prompt ${PREFIXES}
    unset PREFIXES
fi
