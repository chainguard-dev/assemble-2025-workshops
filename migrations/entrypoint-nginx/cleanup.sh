#!/usr/bin/env bash

  for i in 1 2 3 4; do
    docker rm -f mynginx-$i 
    docker rmi mynginx:$i 
  done

  docker rmi localhost:5001/mynginx:5-init localhost:5001/mynginx:5-main cgr.dev/chainguard/wolfi-base:latest
  docker rm -f kind-control-plane kind-registry

  echo "Not removing kindest/node or registry images in case you want to run it again."
  echo "Remove them manually if you what to reclaim the space."