#!/bin/bash

set -e

PROJECT_ID="<change-me>"
VERSION=$(git log -1 --pretty=%h)
REPO="us-west1-docker.pkg.dev/$PROJECT_ID/pterodactyl/ui"
# TAG="$REPO$VERSION"
TAG="$REPO:$VERSION-dev-rust-wiper"
# LATEST="${REPO}latest"
BUILD_TIMESTAMP=$( date '+%F_%H:%M:%S' )
# docker build -t "$TAG" -t "$LATEST" --build-arg VERSION="$VERSION" --build-arg BUILD_TIMESTAMP="$BUILD_TIMESTAMP" .
docker build -f wiper.Dockerfile -t "$TAG" --build-arg VERSION="$VERSION" --build-arg BUILD_TIMESTAMP="$BUILD_TIMESTAMP" .
docker push "$TAG"
# docker push "$LATEST"
echo "pushed imaged: $TAG"