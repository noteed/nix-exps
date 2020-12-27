#! /usr/bin/env bash

# Build a Nix-based, Nginx Docker image, using a Nix Docker image.
# See dockerTools documentation:
# https://nixos.org/nixpkgs/manual/#sec-pkgs-dockerTools
#
# This image relies on the cache image built by build-cache.sh.
#
# Contrary to build-web.sh, this scripts is really just a call to `docker
# build`.

set -e

docker build -f images/web-complete.Dockerfile -t web .
