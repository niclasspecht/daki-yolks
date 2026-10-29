<p align="center">
  <a href="https://daki.cc"><img src="https://daki.cc/assets/img/covers/daki-logo.svg" alt="Daki Hosting" width="120"></a>
</p>

<h1 align="center">Daki Yolks</h1>

<p align="center">
  Security-patched Pterodactyl images for Node.js and Python,<br>
  plus ready-to-use custom images for common use cases.<br>
  Built and used by <a href="https://daki.cc">Daki Hosting</a>, free for everyone.
</p>

<p align="center">
  <a href="https://github.com/niclasspecht/daki-yolks/actions/workflows/nodejs.yml"><img src="https://github.com/niclasspecht/daki-yolks/actions/workflows/nodejs.yml/badge.svg" alt="build nodejs"></a>
  <a href="https://github.com/niclasspecht/daki-yolks/actions/workflows/custom-nodejs-playwright.yml"><img src="https://github.com/niclasspecht/daki-yolks/actions/workflows/custom-nodejs-playwright.yml/badge.svg" alt="build custom nodejs-playwright"></a>
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

- **Always patched.** Every 6 hours a workflow checks whether Docker Hub has published a new base image and rebuilds the affected versions. Every Monday all images are rebuilt and tested, and pushed only when Debian, npm or pip packages actually changed.
- **Compatible.** Same packages, entrypoint and behaviour as the ptero-eggs images, so existing servers keep working. You only swap the image name.
- **Tested.** Before every push the image is started the way Wings starts it (non-root user, `STARTUP` variable) and has to run a real TypeScript or Python script.
- **Open.** Public on GHCR, no login needed, `linux/amd64` and `linux/arm64`. Use them on your own panel, no strings attached.

There are two kinds of images:

- **[Base images](#base-images)** in [`base/`](base/) replace the ptero-eggs yolks one to one.
- **[Custom images](#custom-images)** in [`custom/`](custom/) build on a base image and add what a specific use case needs, such as browser libraries for Playwright. Each comes with its own egg.

## Base images

| Language | Tag | Base image | Supported until |
| --- | --- | --- | --- |
| Node.js 26 | `ghcr.io/niclasspecht/daki-yolks:nodejs_26` | `node:26-trixie-slim` | April 2029 |
| Node.js 24 | `ghcr.io/niclasspecht/daki-yolks:nodejs_24` | `node:24-trixie-slim` | April 2028 |
| Node.js 22 | `ghcr.io/niclasspecht/daki-yolks:nodejs_22` | `node:22-trixie-slim` | April 2027 |
| Python 3.15 | `ghcr.io/niclasspecht/daki-yolks:python_3.15` | `python:3.15-slim-trixie` | October 2031 |
| Python 3.14 | `ghcr.io/niclasspecht/daki-yolks:python_3.14` | `python:3.14-slim-trixie` | October 2030 |
| Python 3.13 | `ghcr.io/niclasspecht/daki-yolks:python_3.13` | `python:3.13-slim-trixie` | October 2029 |
| Python 3.12 | `ghcr.io/niclasspecht/daki-yolks:python_3.12` | `python:3.12-slim-trixie` | October 2028 |
| Python 3.11 | `ghcr.io/niclasspecht/daki-yolks:python_3.11` | `python:3.11-slim-trixie` | October 2027 |

**Node.js images** include `build-essential`, `git`, `ffmpeg`, `sqlite3`, `python3`, `curl`, `dig`, `ping`, `zip`, `tini` and the global npm packages `npm@11`, `typescript@6`, `ts-node` and `@types/node`. npm and TypeScript are pinned to the majors of the previous images, because `ts-node` does not work with TypeScript 7.

**Python images** include `gcc`, `g++`, `git`, `ffmpeg`, `curl`, `dig`, `openssh-client`, `procps`, `psmisc`, `patch`, `less` and `tini`.

End-of-life versions (Node.js 18–21, 23, 25 and Python 3.9, 3.10) are not built, because they no longer receive security fixes upstream. The base eggs still list the old ptero-eggs images for them, clearly marked as EOL, so customers who depend on them can keep using them at their own risk.

## Custom images

Custom images start from a base image, so they get the same patches, and add the packages for one use case. They are rebuilt automatically whenever their base image changes. Every custom image has its own folder with a README, the egg and a smoke test.

| Image | Tags | For | Egg |
| --- | --- | --- | --- |
| [Node.js + Playwright](custom/nodejs-playwright/) | `nodejs-playwright_26`, `_24`, `_22` | Browser automation with Playwright or Puppeteer (Chromium, Firefox) without root | [`egg-nodejs-playwright.json`](custom/nodejs-playwright/egg-nodejs-playwright.json) |

All tags live under `ghcr.io/niclasspecht/daki-yolks`, for example `ghcr.io/niclasspecht/daki-yolks:nodejs-playwright_24`.

## Using the images

**In an egg:** replace the entries under *Docker Images* with the tags above, for example:

```
Nodejs 24|ghcr.io/niclasspecht/daki-yolks:nodejs_24
Python 3.13|ghcr.io/niclasspecht/daki-yolks:python_3.13
```

Or use the ready-made eggs:

- **Base eggs** ([`base/nodejs`](base/nodejs/egg-nodejs.json), [`base/python`](base/python/egg-python.json)) replace your existing Node.js and Python eggs: Admin → Nests → open egg → **Update Egg**.
- **Custom eggs** (in each [`custom/`](custom/) folder) are new eggs: Admin → Nests → **Import Egg**.

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

### Disk space on nodes

When a tag gets a new build, the previous one stays on the node without a name until no container uses it anymore, and Docker never removes it by itself. Add a daily cleanup on every Wings node:

```bash
echo '30 4 * * * root docker image prune -f >/dev/null 2>&1' > /etc/cron.d/docker-image-prune
```

Without `-a` this only removes untagged images that no container (running or stopped) uses, so it never touches a server's image.

## Repository layout

```
base/                          drop-in replacements for the ptero-eggs yolks
  nodejs/                      Dockerfile, entrypoint.sh, egg-nodejs.json, test/
  python/                      Dockerfile, entrypoint.sh, egg-python.json, test/
custom/                        use-case images on top of a base image
  nodejs-playwright/           Dockerfile, egg-nodejs-playwright.json, test/, README.md
scripts/                       prepull, migration and restart helpers for panel admins
.github/workflows/
  build.yml                    shared build, smoke test and push
  nodejs.yml, python.yml       version lists of the base images
  custom-<name>.yml            one workflow per custom image
```

## How the builds work

| Trigger | What happens |
| --- | --- |
| Every 6 hours | Compares each Docker Hub base image digest with the one the image was built from, and rebuilds only what changed |
| Monday 03:17 UTC | Rebuilds and tests every base image, pushes only those whose packages changed |
| After a base build | Custom images check their Daki base image the same way and rebuild the versions that changed |
| Push to `main` | Rebuilds and tests the changed image folder, pushes when the image content changed |
| Actions → **Run workflow** | Same as a push, tick *Push all versions* to push even unchanged images |

Every image carries a fingerprint of its build files, Debian packages and npm or pip packages. A rebuild with the same fingerprint and base image is not pushed, so the tag keeps its digest and nodes do not download a new copy of the same image.

Everything runs on free GitHub-hosted runners. Before every push the image is started like Wings starts it, with the image's `test/` folder as server files. To add a version, add it to `versions` in the workflow and add the line to the egg.

### Adding a custom image

1. Create `custom/<name>/` with a `Dockerfile` that starts `FROM ghcr.io/niclasspecht/daki-yolks:<base>_${VERSION}`.
2. Add a smoke test in `custom/<name>/test/` that prints `smoke ok` only if the use case really works.
3. Copy [`custom-nodejs-playwright.yml`](.github/workflows/custom-nodejs-playwright.yml) to `custom-<name>.yml` and adjust `family`, `path`, `base`, `versions` and the test command. `workflow_run` must name the workflow of the base image.
4. Export the egg from the panel into `custom/<name>/egg-<name>.json` and add a short `README.md`.
5. Add a row to [Custom images](#custom-images), the badge at the top and the tags to [`scripts/prepull.sh`](scripts/prepull.sh).

## About Daki Hosting

[Daki Hosting](https://daki.cc) hosts Discord bots, apps and game servers on a customized Pterodactyl panel, in Germany with your data staying in the EU.

- **[Free hosting](https://daki.cc/products/free-bot-hosting):** free forever, no card required. 512 MB RAM, 1 GB disk.
- **[Premium plans](https://daki.cc/products/paid-plans):** from €2/month on AMD Ryzen 9 9900X, DDR5 and NVMe.
- **[Game servers](https://daki.cc/products/budget-game-servers)** and custom VPS or dedicated setups.

These images run every Node.js and Python server at Daki, and the custom images power the premium custom eggs.

## Contributing and support

Issues and pull requests are welcome, whether it's a new version, a missing package, an idea for a custom image or a bug.

Daki customers can get help on [Discord](https://discord.gg/daki) or through a [support ticket](https://billing.daki.cc/tickets/create).

## License

[MIT](LICENSE.md). Based on [ptero-eggs/yolks](https://github.com/ptero-eggs/yolks) by the Pterodactyl team and contributors.
