# Node.js + Playwright: the Daki Node.js image plus every system library Playwright
# needs for Chromium and Firefox, so customers can run `npx playwright install`
# without root. Playwright resolves the package list for Debian 13 itself, so it
# stays correct for new Playwright releases on every rebuild.
ARG NODE_VERSION=24
FROM ghcr.io/niclasspecht/daki-yolks:nodejs_${NODE_VERSION}

# xauth is only a Recommends of xvfb, but xvfb-run needs it.
RUN npx --yes playwright-core@latest install-deps chromium firefox \
    && apt-get install -y --no-install-recommends procps xauth \
    && rm -rf /var/lib/apt/lists/* /root/.npm /tmp/*
