# This file evolved from
#   nixpkgs/nixos/modules/virtualisation/nova-config.nix.
{ lib, ... }:

with lib;

{
  imports = [
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
    <nixpkgs/nixos/modules/profiles/headless.nix>
  ];

  config = {
    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      autoResize = true;
    };

    boot.growPartition = true;
    boot.kernelParams = [ "console=ttyS0" ];
    boot.loader.grub.device = "/dev/vda";
    boot.loader.timeout = 0;

    services.openssh = {
      enable = true;
      permitRootLogin = "no";
      passwordAuthentication = mkDefault false;
      # Fix bug, see
      # http://ktf.github.io/posts/2018-08-27-nixos-on-cern-openstack.html
      extraConfig = ''
        AuthorizedKeysFile .ssh/authorized_keys
      '';
    };

    users.extraUsers.nixos = {
      isNormalUser = true;
      password = "nixos";
      openssh = {
        authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9pA/P3A72o7wCs40rPo4kr91c8OokgJhH0LxKBF0EmiLjY++8Nh3t7avo88fJI86dkBR4SkdmAG+elicNwQc/n7iN4zMOs8Cdbye/ZrN4xoI5OHyAz1OjzYY6Lje0tuFYrQa8XxW3GF6cWVOLE/v6ShlIoUL1QPrwygdREVhh+as4DhJ6G+4qcjQMMSWw9IPIwpKV+Q8TycTVfL/rDnzzadkp5aPmPgpUhXo8mjY0CY7hGxOpmuPDmyEej8aOTl5fR4yyuz/12lglNNCm8UDu8zJbMOKvvyVWQiXoxmnNFg7lAUU/FcLla0JbQx+4szPHfUgqJNYKyoxdGktmx0FvKavPK5df70ezwEnBAqhHauHDu52GsrCSH8ZItgxvts2CowP52X+GDaWsVtNgXOsu2+1FODog/wVHjOadKBOsp0w6tXsf5zcfysANeSHgB79zyAg4NaJ8UpD0g9qdbhzX5zOJ3JCeA/J+ulnHdegRZSbeXlhTCsvAJygHF74RWx0Bcdr1SiUgOj51Wl9aTERgM7wIykHOvEv38T3ZYw7ZVVsV2atcWdqCOsT9OhVOdO5nqgS8Yh3maHoP9fwKoxNZGF650KIl927GQ7l2DKH8aWhqxhxMagtj4zKimpCEUMUQNJFzOQbi9jL5ri9yUA1FqWlCnxc65MTVWQ8FdPp0LQ==" ];
      };
    };

    security.sudo.extraConfig = ''
      nixos ALL=(ALL:ALL) NOPASSWD: ALL
    '';

    services.cloud-init.enable = true;

    # This gets writtent to /etc/cloud/cloud.cfg.
    # This works well locally.
    # This works also on DO but it takes time. I wonder if it could be faster
    # by allowing additional sources.
    services.cloud-init.config = ''
      datasource_list: [ NoCloud, ConfigDrive ]
    '';
  };
}
