#! /usr/bin/env bash

# Build a Nix-based, Nginx Docker image, using a Nix Docker image.
# See dockerTools documentation:
# https://nixos.org/nixpkgs/manual/#sec-pkgs-dockerTools
#
# This image relies on the cache image built by build-cache.sh.

set -e

TAG="$(date --utc --iso-8601)"
TAG="${TAG}-$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1)"

# Build the builder, which will contain the final image.
docker build --build-arg "IMAGE_TAG=${TAG}" -f images/web.Dockerfile -t "builder:${TAG}" .
# Extract the image from the builder.
docker run --rm "builder:${TAG}" cat /result | docker load
# Delete the builder.
docker rmi "builder:${TAG}"

# Make it easy to run the latest image by tagging it as such.
docker tag "web:${TAG}" web:latest
