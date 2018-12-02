with import <nixpkgs> {};
rec {
  exp-01-nginx-configuration = writeTextFile {
    name = "nginx.conf";
    text = (import ./nginx.conf.nix);
  };

  exp-01-nginx = writeScriptBin "run" ''
    #! ${bash}/bin/bash
    echo Running Nginx...
    mkdir -p /tmp/logs
    echo > /tmp/logs/access.log
    echo > /tmp/logs/error.log
    ${nginx}/bin/nginx -p /tmp -c ${exp-01-nginx-configuration}
    ${coreutils}/bin/tail -F /tmp/logs/access.log /tmp/logs/error.log
  '';
}
