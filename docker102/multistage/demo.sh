#! env bash
. ../../base.sh
IMAGE_BASE_NAME="mstage"

function setup {
  # clean out old $IMAGE_BASE_NAME images
  for i in $(docker images -q $IMAGE_BASE_NAME); do
    docker rmi $i
  done

  #make sure the layers images exist
  for i in 1 2; do
    if [ -z "$(docker images -q layers:$i)" ]; then
      docker build . -t layers:$i -f ../layers/Dockerfile.$i
    fi
  done

}

function buildImage {
  docker rm -f $IMAGE_BASE_NAME:$1 2>/dev/null || true
  docker rmi -f $IMAGE_BASE_NAME:$1 2>/dev/null || true
  p "docker build . -t $IMAGE_BASE_NAME:$1 -f Dockerfile.$1"
  docker build . -t $IMAGE_BASE_NAME:$1 -f Dockerfile.$1 --quiet
}

function step1 {
  clear
  banner "Step 1: Using multistage to eliminate unwanted layers"
  wait
  $BATCAT Dockerfile.1
  buildImage 1
  pe "docker images $IMAGE_BASE_NAME"
  pe "docker images layers"

  pe "docker image history $IMAGE_BASE_NAME:1"
  pe "docker image history layers:2"
  wait
}

function step2 {
  banner "Step 2: Copying a dependency to a final stage w/out a package manager"
  $BATCAT Dockerfile.2
  p "docker build . -t $IMAGE_BASE_NAME:2 -f Dockerfile.2"
  docker build . -t $IMAGE_BASE_NAME:2 -f Dockerfile.2 --quiet
  pe "docker run --rm -it $IMAGE_BASE_NAME:2"
  wait
}

function step2a {
  banner "Step 2a: Find out what libraries are needed, target the builder image"
  p "docker build -t $IMAGE_BASE_NAME:2a -f Dockerfile.2 --target=builder ."
  docker build -t $IMAGE_BASE_NAME:2a -f Dockerfile.2 --target=builder . --quiet
  pe "docker run --rm -it --entrypoint sh -u root $IMAGE_BASE_NAME:2a"
  wait
}

function step2b {
  banner "Step 2b: Copy the .so file(s) to the final image"
  $BATCAT Dockerfile.3
  buildImage 3
  pe "docker run --rm -it $IMAGE_BASE_NAME:3"
}

case $1 in
  1) cleanup; step1 ;;
  2) step2 ;;
  2a) step2a ;;
  2b) step2b ;;
  *) setup; step1; step2; step2a; step2b ;;
esac