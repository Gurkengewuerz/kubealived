#!/bin/bash

REGISTRY="docker.io"
USERNAME="gurken2108"
PROJECT="kubealived"

get_latest_release() {
  git ls-remote --refs --sort="version:refname" --tags https://github.com/$1.git | cut -d/ -f3- | tail -n1
}

LATEST=$(get_latest_release acassen/keepalived)
LATEST_RAW=$(echo $LATEST | cut -c 2-)
git clone --depth 1 --branch ${LATEST} https://github.com/acassen/keepalived.git src/

echo -e "Current acassen/keepalived version is version $LATEST_RAW"

#docker build -t ${REGISTRY}/${USERNAME}/${PROJECT}:latest .

docker buildx create --use --name ${USERNAME}-${PROJECT}
docker buildx build \
  --platform linux/amd64,linux/arm/v7,linux/arm64 \
  --push \
  -t ${REGISTRY}/${USERNAME}/${PROJECT}:latest \
  -t ${REGISTRY}/${USERNAME}/${PROJECT}:${LATEST_RAW} \
  .
docker buildx stop ${USERNAME}-${PROJECT}
docker buildx rm ${USERNAME}-${PROJECT}

rm -rf src
docker image prune -f