#! /usr/bin/env bash

# Build a Nix-based, Nginx Docker image, using a Nix Docker image.
# See dockerTools documentation:
# https://nixos.org/nixpkgs/manual/#sec-pkgs-dockerTools
#
# These two images can be built, say, once a week.

set -e

# Build the base image.
docker build -f images/nix-base.Dockerfile -t nix-base .

# Build the cache image.
docker build -f images/nix-cache.Dockerfile -t nix-cache .
