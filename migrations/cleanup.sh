#!/usr/bin/env bash

entrypoint-nginx/cleanup.sh
entrypoint-py/cleanup.sh

echo "Most images and containers removed, you may want to run "docker image prune" or "docker system prune" to reclaim space."