ARG PG_MAJOR=18
FROM postgres:${PG_MAJOR}-alpine

# initdb needs a passwd entry for the UID it runs as, and that UID depends on the
# Wings config (system.user.uid). entrypoint.sh adds it at runtime, so /etc/passwd is
# writable. This grants nothing: the image has no setuid binaries, which the last line
# of this RUN checks so a future base image cannot silently change that.
RUN apk add --no-cache bash ca-certificates iproute2 tzdata \
    && chmod 666 /etc/passwd \
    && if find / -xdev -perm -4000 -type f | grep .; then echo "setuid binaries found" >&2; exit 1; fi

ENV USER=container HOME=/home/container
WORKDIR /home/container
STOPSIGNAL SIGTERM

COPY --chown=root:root --chmod=755 entrypoint.sh /entrypoint.sh
COPY --chown=root:root --chmod=755 daki-postgres /usr/local/bin/daki-postgres
ENTRYPOINT ["/entrypoint.sh"]
CMD []
