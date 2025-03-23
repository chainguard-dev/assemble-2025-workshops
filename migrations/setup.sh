#!/usr/bin/env bash
export DOCKER_CLI_HINTS=false

echo "Attempting to pull the cgr.dev/chainguard/wolfi-base image..."
if ! docker pull cgr.dev/chainguard/wolfi-base; then
  echo "Error: Failed to pull the Docker image via: docker pull cgr.dev/chainguard/wolfi-base"
  echp "Please check your Docker configuration or network connection."
  exit 1
fi
echo "Successfully pulled the Docker image." 
echo
echo
echo -n "Checking for kubectl... "
if ! command -v kubectl &> /dev/null; then
  echo "Error: kubectl could not be found. Please install it to proceed."
  exit 1
fi
echo "found!"
echo

KIND_PRESENT=false
echo -n "Checking for kind..."
if ! command -v kind &> /dev/null; then
  echo "not found!"
  echo "   kind does not appear to be installed, are you planning on using a different kubernetes provider? (y/n)"
  read -r answer
  if [[ "$answer" != "y" ]]; then
    echo "Please refer to the installation instructions for kind: https://kind.sigs.k8s.io/docs/user/quick-start/#installation"
    echo "Re-run this script once you have kind installed."
    exit 1
  fi
else
  echo "found!"
  KIND_PRESENT=true
fi

echo
echo -n "Checking if a kubernetes cluster is running and configured... "
if ! kubectl version &> /dev/null; then
  echo "Failed to connect to a cluster"
  if $KIND_PRESENT; then
    echo "   You appear to have kind installed, would you like to create the workshop kind cluster now by running ./kind-setup.sh? (y/n)"
    read -r answer
    if [[ "$answer" == "y" ]]; then
      ./kind-setup.sh
    else
      echo "Please ensure you have a running kubernetes cluster and re-run this script."
      exit 1
    fi
  else
    echo "Please ensure you have a running kubernetes cluster and re-run this script."
    exit 1
  fi
fi

echo
echo "All checks passed. You are ready to participate in the workshop!"


