#!/bin/bash
# Run on every Wings node so restarts don't have to wait for the download.
set -e
IMAGE=ghcr.io/niclasspecht/daki-yolks
for v in nodejs_22 nodejs_24 nodejs_26 python_3.11 python_3.12 python_3.13 python_3.14 python_3.15; do
  docker pull "$IMAGE:$v"
done
