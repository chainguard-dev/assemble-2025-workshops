#! env bash
. ../../base.sh
IMAGE_BASE_NAME="pyapp"

function buildImage {
  docker rm -f $IMAGE_BASE_NAME:$1 2>/dev/null || true
  docker rmi -f $IMAGE_BASE_NAME:$1 2>/dev/null || true
  p "docker build . -t $IMAGE_BASE_NAME:$1 -f Dockerfile.$1"
  docker build . -t $IMAGE_BASE_NAME:$1 -f Dockerfile.$1 --quiet
}

function runContainer {
  local port=$((9000 + $1))
  docker rm -f $IMAGE_BASE_NAME-$1 2>/dev/null || true
  pe "docker run -d -p $port:5000 --name $IMAGE_BASE_NAME-$1 $IMAGE_BASE_NAME:$1"
  pe "docker logs $IMAGE_BASE_NAME-$1"
  pe "curl -s http://localhost:$port/"
  echo
  wait
}

function step1 {
  clear
  banner "Step 1: This Python app image uses an entrypoint shell script to reach out to a web service to gather runtime-needed data"
  wait
  $BATCAT Dockerfile.1
  $BATCAT start.sh
  buildImage 1 
  runContainer 1 
}

function step2 {
  clear
  banner "Step 2: Convert to multi-stage build with a distroless-type python image"
  wait
  $BATCAT Dockerfile.2
  buildImage 2
  runContainer 2
}

function step3 {
  clear
  banner "Step 3: We don't have Kubernetes to help. One option is to port the start.sh script to Python"
  wait
  $BATCAT Dockerfile.3
  $BATCAT start.sh
  $BATCAT start.py
  buildImage 3
  runContainer 3 
}

function step4 {
  docker-compose down --volumes
  clear
  banner "Step 4: Another option - If you can use docker-compose, you can do something similar to an k8s initContainer"
  wait
  $BATCAT Dockerfile.4
  wait
  $BATCAT docker-compose.yaml
  buildImage 4
  pe "docker-compose up -d"
  pe "docker-compose logs -f"
  pe "curl -s http://localhost:9004/"
}

case $1 in
  1) step1 ;;
  2) step2 ;;
  3) step3 ;;
  4) step4 ;;
  *) step1; step2; step3; step4;;
esac
