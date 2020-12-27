# This is similar to web.Dockerfile, this time with a second step to make a
# rootfs ready to be ADDed to a FROM scratch image.
#
# This makes it easier to build the image with a regular call to `docker build`
# instead of relying on a script such as build-web.sh.
FROM nix-cache AS web-builder

ADD images.nix .
RUN nix-build images.nix --attr web --argstr tag dummy --out-link image
RUN nix-build images.nix --attr web-cmd --out-link cmd

# Convert the Docker tarball to OCI format, then extract that format to
# a rootfs.
RUN nix-shell -p skopeo --run \
  'skopeo --insecure-policy copy docker-archive:image oci:dummy:dummy'
RUN nix-shell -p umoci --run \
  'umoci raw unpack --image dummy:dummy rootfs'


FROM scratch
COPY --from=web-builder /rootfs/ /
COPY --from=web-builder /cmd /run.sh
CMD ["/run.sh"]
