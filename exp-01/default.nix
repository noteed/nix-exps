with import <nixpkgs> {};
rec {
  exp-01-nginx-configuration = writeTextFile {
    name = "nginx.conf";
    text = (import ./nginx.conf.nix);
  };

  exp-01-nginx = writeScriptBin "run" ''
    #! ${bash}/bin/bash
    echo Running Nginx...
    mkdir /tmp/logs
    ${nginx}/bin/nginx -p /tmp -c ${exp-01-nginx-configuration}
    ${coreutils}/bin/tail -F /tmp/access.log /tmp/error.log
  '';
}
