#!/bin/bash
cd /home/container || exit 1

# /etc/passwd is a link to /tmp/passwd (the root filesystem is read-only under Wings).
# initdb needs an entry for the UID Wings runs the container as.
cp /etc/passwd.dist /tmp/passwd
if ! awk -F: -v uid="$(id -u)" '$3 == uid { found = 1 } END { exit !found }' /tmp/passwd; then
    echo "container:x:$(id -u):$(id -g):container:/home/container:/bin/sh" >>/tmp/passwd
fi

# Make internal Docker IP address available to processes.
INTERNAL_IP=$(ip route get 1 2>/dev/null | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Replace Startup Variables
MODIFIED_STARTUP=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo ":/home/container$ ${MODIFIED_STARTUP}"

# exec: the startup command becomes PID 1 and receives SIGTERM directly, so PostgreSQL
# is shut down cleanly when the container is stopped.
eval "exec ${MODIFIED_STARTUP}"
