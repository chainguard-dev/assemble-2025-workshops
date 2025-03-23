#! env bash
. ../../base.sh
IMAGE_BASE_NAME="mynginx"

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
  banner "Step 1: Starting from an nginx server that uses an entrypoint shell script"
  $BATCAT Dockerfile.1
  $BATCAT start.sh
  $BATCAT html/index.html
  buildImage 1 
  runContainer 1 "Buggs Bunny" "Loony Tunes"
}

function step2 {
  clear
  banner "Step 2: Switching to a distroless-type nginx image"
  $BATCAT Dockerfile.2
  buildImage 2
  echo
  wait
}

function step3 {
  clear
  banner "Step 3: Use the -dev tag but remove packages I don't need"
  $BATCAT Dockerfile.3
  buildImage 3
  runContainer 3 "Yoda" "Degoba"
  pe "docker images $IMAGE_BASE_NAME"
  pe "syft $IMAGE_BASE_NAME:1"
  pe "syft $IMAGE_BASE_NAME:3"
  echo
  wait
}

function step4 {
  clear
  banner "Step 4: Create a chrooted nginx image and apk add into it"
  $BATCAT Dockerfile.4
  buildImage 4
  runContainer 4 "Ivanava" "Babylon 5"
  pe "docker images $IMAGE_BASE_NAME"
  pe "syft $IMAGE_BASE_NAME:4"
  echo
  wait
}

function step5 {
  clear
  kubectl delete -f web.yaml 2>/dev/null || true
  banner "Step 5: Use a Kubernetes InitContainer for initalization, and a final image with no extras"
  $BATCAT Dockerfile.5-init
  $BATCAT Dockerfile.5-main
  buildImage 5-init
  buildImage 5-main
  $BATCAT web.yaml
  pe "kubectl apply -f web.yaml"
  pe "kubectl get pod -w"
  pe "kubectl get all"
  pe "kubectl port-forward svc/nginx-service 8085:80"
  pe "docker images $IMAGE_BASE_NAME"
  pe "syft $IMAGE_BASE_NAME:5-main"
  echo
  wait
}

case $1 in
  1) step1 ;;
  2) step2 ;;
  3) step3 ;;
  4) step4 ;;
  5) step5 ;;
  *) step1; step2; step3; step4; step5;;
esac
