ARG PYTHON_VERSION=3.14
FROM python:${PYTHON_VERSION}-slim-trixie

# less, openssh-client, patch and psmisc came in as recommends in the previous images.
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl dnsutils ffmpeg g++ gcc git iproute2 less \
    openssh-client patch procps psmisc tini \
    && rm -rf /var/lib/apt/lists/*

ENV USER=container HOME=/home/container
WORKDIR /home/container
STOPSIGNAL SIGINT

COPY --chown=root:root --chmod=755 entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
