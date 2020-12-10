#!/usr/bin/env sh
set -euf

# Ensure that /data is mounted with execute permissions
MOUNT_OUTPUT=$(mount | grep " /data ")
case "${MOUNT_OUTPUT}" in
*noexec*)
    echo ""
    echo "ERROR"
    echo "Your /data mount does not allow execution, as the \"noexec\" flag is present:"
    echo ""
    echo "${MOUNT_OUTPUT}"
    echo ""
    echo "In order for this container to work correctly, either remove \"noexec\""
    echo "from the host mount options that /data is using (usually by editing"
    echo "the hosts /etc/fstab file), or choose a different location on the host"
    echo "for the /data volume that allows execution."
    exit 1
    ;;
esac
