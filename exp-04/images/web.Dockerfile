# The real meat, reusing the above image to benefit from the cached Nix store.
FROM nix-cache AS web-builder

# The tag used to name the resulting image.
ARG IMAGE_TAG

ADD images.nix .
RUN nix-build images.nix --attr web --argstr tag $IMAGE_TAG
