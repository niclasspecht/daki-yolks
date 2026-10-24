ARG NODE_VERSION=24
FROM node:${NODE_VERSION}-trixie-slim AS base

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential ca-certificates curl dnsutils ffmpeg git iproute2 \
    iputils-ping libnss3 libsqlite3-dev libtool python3 python3-dev \
    sqlite3 tar tini tzdata zip \
    && rm -rf /var/lib/apt/lists/*

# Pinned to the majors of the previous images: ts-node does not work with TypeScript 7.
RUN npm install --global npm@11 typescript@6 ts-node @types/node

ENV USER=container HOME=/home/container
WORKDIR /home/container
STOPSIGNAL SIGINT

COPY --chown=root:root --chmod=755 entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]

# Playwright variant (nodejs-playwright_<version>): system libraries for Chromium and
# Firefox, so customers can run `npx playwright install` without root.
# Playwright resolves the package list for Debian 13 itself, so it stays correct
# for new Playwright releases on every weekly rebuild.
FROM base AS playwright
RUN npx --yes playwright-core@latest install-deps chromium firefox \
    && apt-get install -y --no-install-recommends procps xauth \
    && rm -rf /var/lib/apt/lists/* /root/.npm /tmp/*

# Default target: the plain image without browser libraries.
FROM base
