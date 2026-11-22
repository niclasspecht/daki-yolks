#!/bin/bash
cd /home/container || exit 1

# initdb needs a passwd entry for the UID Wings runs the container as.
if ! getent passwd "$(id -u)" >/dev/null 2>&1 && [ -w /etc/passwd ]; then
    echo "container:x:$(id -u):$(id -g):container:/home/container:/bin/sh" >>/etc/passwd
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
