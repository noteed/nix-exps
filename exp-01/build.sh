#! /usr/bin/env bash

set -e

# Build the image to run closure tarballs (such as the one built below).
docker build -t hypered/nix images/nix

# Clean previous build.
rm -rf ./cache closure.tar result

# Build the tarball (containing the result symlink and its closure).
nix-build -A exp-01-nginx
# nix-push --dest $(pwd)/cache result                      # Before Nix 2
nix copy --to "file://$(pwd)/cache" $(readlink -f result)  # With Nix 2
tar cf closure.tar cache result

echo
echo You can run something like:
echo 'docker run -d -p 8080:8080 -v $(pwd)/closure.tar:/closure.tar hypered/nix'
echo 'curl http://127.0.0.1:8080'
