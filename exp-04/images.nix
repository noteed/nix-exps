# This file defines a Docker image built with dockerTools.
{ pkgs ? import <nixpkgs> {}
, tag ? "latest"
}:
let
  nginxPort = "80";
  nginxConf = pkgs.writeText "nginx.conf" ''
    user nginx nginx;
    daemon off;
    error_log /dev/stdout info;
    pid /dev/null;
    events {}
    http {
      access_log /dev/stdout;
      server {
        listen ${nginxPort};
        index index.html;
        location / {
          root ${nginxWebRoot};
        }
      }
    }
  '';
  nginxWebRoot = pkgs.writeTextDir "index.html" ''
    <!DOCTYPE html>
    <code><pre>
    <span style="color: gray;">noteed/nix-exps</span>
    <strong>Exp-04</strong>

    This page is served from a dockerTools-built Nginx image.
    </pre></code>
  '';
  # This could be in a runAsRoot parameter below, but
  # runAsRoot requires KVM when building the image. Since
  # we want to be able to build within a Dokcer container,
  # we can't use it.
  nginxSetup = pkgs.writeScript "setup"
  ''
    #!${pkgs.stdenv.shell}
    export PATH=${pkgs.coreutils}/bin
    ${pkgs.dockerTools.shadowSetup}
    groupadd --system nginx
    useradd --system --gid nginx nginx

    exec ${pkgs.nginx}/bin/nginx -c ${nginxConf}
  '';
in
{
  # An Nginx server.
  web = pkgs.dockerTools.buildImage {
    name = "web";
    tag = "${tag}";
    created = "now";  # WARNING: this is impure.

    extraCommands = ''
      # Nginx still tries to read this directory, even if the
      # error_log directive specifies another file.
      mkdir -p var/log/nginx
      mkdir -p var/cache/nginx
    '';

    config = {
      Cmd = [ nginxSetup ];
      ExposedPorts = {
        "${nginxPort}/tcp" = {};
      };
    };
  };
}
