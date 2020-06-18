# This is a Nix-based image, intended to build Docker images using the
# dockerTools function from nixpkgs.
#
# Build as nix-base.
#
FROM nixos/nix AS nix-base

# TODO Use NIX_PATH instead of channels.
RUN nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
RUN nix-channel --update
