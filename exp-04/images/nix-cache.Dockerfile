# Actually build some image, to populate the Nix store and keep it around
# as a cached Docker layer. Even if images.nix changes a bit, no need to
# systematically rebuild it. Here we build "web" but this could be another
# one, or a combination of multiple images.
#
# Build as nix-cache.
#
FROM nix-base AS nix-cache

ADD images.nix .
RUN nix-build images.nix --attr web --no-out-link
