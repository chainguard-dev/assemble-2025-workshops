#!/usr/bin/env bash

  for i in 1 2 3 4 4-init; do
    docker rm -f pyapp-$i 
    docker rmi -f pyapp:$i 
  done
  
  docker rmi cgr.dev/chainguard/curl:latest
