#!/usr/bin/env bash

  for i in 1 2 2a 3 4 5; do
    docker rmi mstage:$i 
  done
