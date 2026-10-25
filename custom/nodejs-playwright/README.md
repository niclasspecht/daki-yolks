# Node.js + Playwright

The [Daki Node.js image](../../base/nodejs/) plus every system library Playwright needs for Chromium and Firefox. Built for Discord bots and apps that use Playwright or Puppeteer on a panel where servers run without root.

| Tag | Based on |
| --- | --- |
| `ghcr.io/niclasspecht/daki-yolks:nodejs-playwright_26` | `nodejs_26` |
| `ghcr.io/niclasspecht/daki-yolks:nodejs-playwright_24` | `nodejs_24` |
| `ghcr.io/niclasspecht/daki-yolks:nodejs-playwright_22` | `nodejs_22` |

## Why

`npx playwright install --with-deps` installs system packages with apt and fails without root (`su: Authentication failure`). Without those packages Chromium exits with errors like `libatk-1.0.so.0: cannot open shared object file`. This image ships the packages, so customers only download the browsers, which works as a normal user.

## What's inside

- Everything from the Node.js base image
- System libraries for Chromium and Firefox, resolved by `playwright install-deps` for Debian 13 on every rebuild
- Xvfb and `xauth` for headed browsers, `procps` to find and kill stuck browser processes
- Fonts for Latin, CJK, Thai and emoji

The browsers themselves are not in the image. Each Playwright version needs its own browser build, so they are installed per server into `/home/container/.cache/ms-playwright`.

## Egg

[`egg-nodejs-playwright.json`](egg-nodejs-playwright.json) is the Node.js egg with one extra variable:

| Variable | Default | Effect |
| --- | --- | --- |
| `PLAYWRIGHT_INSTALL` | `chromium` | Arguments for `playwright install`, run on every start after `npm install` with the Playwright version from `node_modules`. Already installed browsers are skipped. Empty disables it. |

Useful values: `chromium`, `chromium firefox`, or `chromium --only-shell`, which only installs the headless shell and saves about 190 MB of disk.

## Notes for customers

- Run the browser headless, which is Playwright's default. Chromium and Firefox headless are covered by the smoke test, screenshots included.
- For headed mode, start with `xvfb-run -a -s "-screen 0 1920x1080x24" node index.js`. Headed Chromium on Xvfb has no GPU and cannot take screenshots.
- Chromium needs a lot of RAM. 512 MB is enough for one page at a time; for several pages in parallel, use a bigger plan.
- Puppeteer works too. It downloads its own Chrome into `~/.cache/puppeteer` and uses the same libraries.

## Test

[`test/smoke.mjs`](test/smoke.mjs) installs Playwright like a customer would. It then launches Chromium and Firefox headless and Chromium headed, renders Latin, CJK and emoji text and takes screenshots in headless mode.
