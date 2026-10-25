#!/bin/bash
# Run on every Wings node so restarts don't have to wait for the download.
set -e
IMAGE=ghcr.io/niclasspecht/daki-yolks
BASE="nodejs_22 nodejs_24 nodejs_26 python_3.11 python_3.12 python_3.13 python_3.14 python_3.15"
CUSTOM="nodejs-playwright_22 nodejs-playwright_24 nodejs-playwright_26"
for v in $BASE $CUSTOM; do
  docker pull "$IMAGE:$v"
done
