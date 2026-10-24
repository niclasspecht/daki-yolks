<p align="center">
  <a href="https://daki.cc"><img src="https://daki.cc/assets/img/covers/daki-logo.svg" alt="Daki Hosting" width="120"></a>
</p>

<h1 align="center">Daki Yolks</h1>

<p align="center">
  Security-patched Pterodactyl images for Node.js and Python.<br>
  Built and used by <a href="https://daki.cc">Daki Hosting</a>, free for everyone.
</p>

<p align="center">
  <a href="https://github.com/niclasspecht/daki-yolks/actions/workflows/nodejs.yml"><img src="https://github.com/niclasspecht/daki-yolks/actions/workflows/nodejs.yml/badge.svg" alt="build nodejs"></a>
  <a href="https://github.com/niclasspecht/daki-yolks/actions/workflows/nodejs-playwright.yml"><img src="https://github.com/niclasspecht/daki-yolks/actions/workflows/nodejs-playwright.yml/badge.svg" alt="build nodejs-playwright"></a>
  <a href="https://github.com/niclasspecht/daki-yolks/actions/workflows/python.yml"><img src="https://github.com/niclasspecht/daki-yolks/actions/workflows/python.yml/badge.svg" alt="build python"></a>
  <a href="LICENSE.md"><img src="https://img.shields.io/badge/license-MIT-blue" alt="MIT license"></a>
  <a href="https://discord.gg/daki"><img src="https://img.shields.io/badge/discord-join-5865F2?logo=discord&logoColor=white" alt="Discord"></a>
</p>

<p align="center">
  <a href="https://daki.cc">Website</a> ·
  <a href="https://daki.cc/products/free-bot-hosting">Free Hosting</a> ·
  <a href="https://daki.cc/products/paid-plans">Premium Plans</a> ·
  <a href="https://daki.cc/wiki">Wiki</a> ·
  <a href="https://daki.cc/status">Status</a> ·
  <a href="https://discord.gg/daki">Discord</a>
</p>

---

## What is this?

Pterodactyl runs every server inside a Docker image, a so-called *yolk*. Most panels use the community images from [ptero-eggs/yolks](https://github.com/ptero-eggs/yolks). Those were last rebuilt in June 2026, so they still ship Node.js versions without the fixes from the [October 2026 security release](https://nodejs.org/en/blog/vulnerability/october-2026-security-releases), along with outdated Debian packages.

Daki Yolks are drop-in replacements for those images:

- **Always patched.** Every 6 hours a workflow checks whether Docker Hub has published a new base image and rebuilds the affected versions. Every Monday all images are rebuilt to pick up Debian package updates.
- **Compatible.** Same packages, entrypoint and behaviour as the ptero-eggs images, so existing servers keep working. You only swap the image name.
- **Tested.** Before every push the image is started the way Wings starts it (non-root user, `STARTUP` variable) and has to run a real TypeScript or Python script.
- **Open.** Public on GHCR, no login needed, `linux/amd64` and `linux/arm64`. Use them on your own panel, no strings attached.

## Images

| Language | Tag | Base image | Supported until |
| --- | --- | --- | --- |
| Node.js 26 | `ghcr.io/niclasspecht/daki-yolks:nodejs_26` | `node:26-trixie-slim` | April 2029 |
| Node.js 24 | `ghcr.io/niclasspecht/daki-yolks:nodejs_24` | `node:24-trixie-slim` | April 2028 |
| Node.js 22 | `ghcr.io/niclasspecht/daki-yolks:nodejs_22` | `node:22-trixie-slim` | April 2027 |
| Node.js 26 + Playwright | `ghcr.io/niclasspecht/daki-yolks:nodejs-playwright_26` | `node:26-trixie-slim` | April 2029 |
| Node.js 24 + Playwright | `ghcr.io/niclasspecht/daki-yolks:nodejs-playwright_24` | `node:24-trixie-slim` | April 2028 |
| Node.js 22 + Playwright | `ghcr.io/niclasspecht/daki-yolks:nodejs-playwright_22` | `node:22-trixie-slim` | April 2027 |
| Python 3.15 | `ghcr.io/niclasspecht/daki-yolks:python_3.15` | `python:3.15-slim-trixie` | October 2031 |
| Python 3.14 | `ghcr.io/niclasspecht/daki-yolks:python_3.14` | `python:3.14-slim-trixie` | October 2030 |
| Python 3.13 | `ghcr.io/niclasspecht/daki-yolks:python_3.13` | `python:3.13-slim-trixie` | October 2029 |
| Python 3.12 | `ghcr.io/niclasspecht/daki-yolks:python_3.12` | `python:3.12-slim-trixie` | October 2028 |
| Python 3.11 | `ghcr.io/niclasspecht/daki-yolks:python_3.11` | `python:3.11-slim-trixie` | October 2027 |

**Node.js images** include `build-essential`, `git`, `ffmpeg`, `sqlite3`, `python3`, `curl`, `dig`, `ping`, `zip`, `tini` and the global npm packages `npm@11`, `typescript@6`, `ts-node` and `@types/node`. npm and TypeScript are pinned to the majors of the previous images, because `ts-node` does not work with TypeScript 7.

**Node.js + Playwright images** are the Node.js images plus every system library Playwright needs for Chromium and Firefox (resolved by `playwright install-deps` for Debian 13), Xvfb for headed browsers, fonts for CJK and emoji, `xauth` (for `xvfb-run`) and `procps`. Customers cannot run `--with-deps` themselves because servers run without root, so the libraries live in the image and the browsers themselves are installed per server with plain `npx playwright install chromium`, matching the Playwright version in their `node_modules`. The [Playwright egg](eggs/egg-nodejs-playwright.json) does this automatically on every start. Puppeteer works with the same libraries.

**Python images** include `gcc`, `g++`, `git`, `ffmpeg`, `curl`, `dig`, `openssh-client`, `procps`, `psmisc`, `patch`, `less` and `tini`.

End-of-life versions (Node.js 18–21, 23, 25 and Python 3.9, 3.10) are not built, because they no longer receive security fixes upstream. The eggs in this repository still list the old ptero-eggs images for them, clearly marked as EOL, so customers who depend on them can keep using them at their own risk.

## Using the images

**In an egg:** replace the entries under *Docker Images* with the tags above, for example:

```
Nodejs 24|ghcr.io/niclasspecht/daki-yolks:nodejs_24
Python 3.13|ghcr.io/niclasspecht/daki-yolks:python_3.13
```

Or import the ready-made eggs from [`eggs/`](eggs/) (Admin → Nests → open egg → **Update Egg**).

**With Docker directly:**

```bash
docker pull ghcr.io/niclasspecht/daki-yolks:nodejs_24
```

## Switching an existing panel

Running servers keep their old image until they are restarted. On start, Wings removes the old container, pulls the image and creates a new container. Server files in `/home/container` are not touched.

1. Update the eggs (see above). This only affects new servers and the image picker in the client panel.
2. Pre-pull the images on every node: [`scripts/prepull.sh`](scripts/prepull.sh)
3. Point existing servers at the new images: [`scripts/migrate-images.sql`](scripts/migrate-images.sql). Only versions that Daki Yolks builds are changed, EOL versions stay on their image.
4. Restart running servers: [`scripts/restart-servers.sh`](scripts/restart-servers.sh) (dry run by default). Stopped servers pick up the new image on their next start.

When only the patch version changes (for example ptero-eggs `nodejs_24` → Daki `nodejs_24`), nothing else is needed. Python 3.11–3.13 also move from Debian 12 to Debian 13, which existing pip packages handle fine. After a major upgrade (for example Node.js 25 → 26 or Python 3.10 → 3.11), native modules need `npm rebuild` and Python virtual environments have to be recreated.

After every rebuild the tag stays the same. A restart is enough for a server to get the latest patches.

## How the builds work

| Trigger | What happens |
| --- | --- |
| Every 6 hours | Compares each base image digest with the one the image was built from, and rebuilds only what changed |
| Monday 03:17 UTC | Rebuilds every version |
| Push to `main` | Rebuilds the changed language |
| Actions → **Run workflow** | Manual rebuild |

Everything runs on free GitHub-hosted runners: [`build.yml`](.github/workflows/build.yml) is shared, [`nodejs.yml`](.github/workflows/nodejs.yml), [`nodejs-playwright.yml`](.github/workflows/nodejs-playwright.yml) and [`python.yml`](.github/workflows/python.yml) hold the version lists. To add a version, add it to `versions` there and add the line to the egg.

## About Daki Hosting

[Daki Hosting](https://daki.cc) hosts Discord bots, apps and game servers on a customized Pterodactyl panel, in Germany with your data staying in the EU.

- **[Free hosting](https://daki.cc/products/free-bot-hosting):** free forever, no card required. 512 MB RAM, 1 GB disk.
- **[Premium plans](https://daki.cc/products/paid-plans):** from €2/month on AMD Ryzen 9 9900X, DDR5 and NVMe.
- **[Game servers](https://daki.cc/products/budget-game-servers)** and custom VPS or dedicated setups.

These images run every Node.js and Python server at Daki.

## Contributing and support

Issues and pull requests are welcome, whether it's a new version, a missing package or a bug.

Daki customers can get help on [Discord](https://discord.gg/daki) or through a [support ticket](https://billing.daki.cc/tickets/create).

## License

[MIT](LICENSE.md). Based on [ptero-eggs/yolks](https://github.com/ptero-eggs/yolks) by the Pterodactyl team and contributors.
