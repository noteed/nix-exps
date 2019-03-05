# This file evolved from
#   nixpkgs/nixos/maintainers/scripts/openstack/nova-image.nix
#
# To build:
#
#   nix-build '<nixpkgs/nixos>' \
#     -A config.system.build.qcow2 \
#     --arg configuration "{ imports = [ ./qcow2.nix ]; }"
#
# To run the result:
#
#   qemu-kvm -hda result/nixos.qcow2 \
#     -m 4096 \
#     -drive file=cidata.img,if=virtio \
#     -nic user,hostfwd=tcp:127.0.0.1:2222-:22 \
#     -no-reboot -snapshot -nographic
#
# Once running, it should be possible to SSH into the VM with:
#   ssh -p 2222 nixos@127.0.0.1
#
# Stopping the VM can be done with C-a x in the original shell.

{ config, lib, pkgs, ... }:

with lib;

{
  imports =
    [ <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
      ./config.nix
    ];

  system.build.qcow2 = import <nixpkgs/nixos/lib/make-disk-image.nix> {
    inherit lib config;

    # Ensure we use the regular qemu-kvm package.
    pkgs = import <nixpkgs> { inherit (pkgs) system; };

    # The file is "unused" until the nixos-rebuild switch.
    configFile = ./config.nix;

    format = "qcow2";
    diskSize = 8192;
  };
}
