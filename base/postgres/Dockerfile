ARG PG_MAJOR=18
FROM postgres:${PG_MAJOR}-alpine

RUN apk add --no-cache bash ca-certificates iproute2 tzdata

ENV USER=container HOME=/home/container
WORKDIR /home/container
STOPSIGNAL SIGTERM

COPY --chown=0:0 --chmod=755 entrypoint.sh /entrypoint.sh
COPY --chown=0:0 --chmod=755 daki-postgres /usr/local/bin/daki-postgres

# initdb needs a passwd entry for the UID it runs as. That UID comes from the Wings
# config (system.user.uid), and Wings mounts the root filesystem read-only with a
# writable tmpfs on /tmp. So /etc/passwd points to /tmp/passwd, which entrypoint.sh
# writes on every start from passwd.dist plus the current UID.
# The image has no setuid binaries (checked here), so this grants nothing.
RUN cp /etc/passwd /etc/passwd.dist \
    && ln -sf /tmp/passwd /etc/passwd \
    && if find / -xdev -perm -4000 -type f | grep .; then echo "setuid binaries found" >&2; exit 1; fi

ENTRYPOINT ["/entrypoint.sh"]
CMD []
