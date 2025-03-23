#! env bash
. ../../base.sh
IMAGE_BASE_NAME="layers"

function cleanup {
  TAGS=$(docker images layers --format json  | jq -r .Tag)
  for tag in $TAGS; do
    docker rmi layers:$tag
  done
}

function buildImage {
  docker rm -f $IMAGE_BASE_NAME:$1 2>/dev/null || true
  docker rmi -f $IMAGE_BASE_NAME:$1 2>/dev/null || true
  p "docker build . -t $IMAGE_BASE_NAME:$1 -f Dockerfile.$1"
  docker build . -t $IMAGE_BASE_NAME:$1 -f Dockerfile.$1 --quiet
}

function runContainer {
  local port=$((8080 + $1))
  docker rm -f $IMAGE_BASE_NAME-$1 2>/dev/null || true
  pe "docker run -d -p $port:8080 -e MY_NAME='$2' -e MY_ENV='$3' --name $IMAGE_BASE_NAME-$1 $IMAGE_BASE_NAME:$1"
  pe "curl -s http://localhost:$port/"
  echo
  wait
}

function step1 {
  clear
  banner "Step 1: Get a big file, untar it, and remove the tarball"
  $BATCAT Dockerfile.1
  buildImage 1
  pe "docker images $IMAGE_BASE_NAME"
  pe "docker image history $IMAGE_BASE_NAME:1"
  wait
}

function step2 {
  clear
  banner "Step 2: Concatenate operations into a single RUN line"
  $BATCAT Dockerfile.2
  buildImage 2
  pe "docker images $IMAGE_BASE_NAME"
  p "diff Dockerfile.1 Dockerfile.2"
  diff --color=always Dockerfile.1 Dockerfile.2
  pe "docker image history $IMAGE_BASE_NAME:1"
  pe "docker image history $IMAGE_BASE_NAME:2"
}


case $1 in
  1) cleanup; step1 ;;
  2) step2 ;;
  *) cleanup; step1; step2 ;;
esac