{ pkgs ? import <nixpkgs> { } } : rec {

  # This represents our supervised service.
  dummy_script = pkgs.writeScript "dummy" ''
    #! ${pkgs.execline}/bin/execlineb -W
    foreground { echo Dummy is starting... }
    foreground { sleep 60 }
    echo Dummy is exiting...
  '';

  dummy = pkgs.stdenv.mkDerivation {
    name = "dummy";
    src = ./.;
    installPhase = ''
      mkdir -p $out
      cp -a ${dummy_script} $out/run
    '';
  };

  run_services_finish = pkgs.writeScript "finish" ''
    #! ${pkgs.execline}/bin/execlineb -W
    echo run-services svscan told to finish.
  '';

  run_services_crash = pkgs.writeScript "crash" ''
    #! ${pkgs.execline}/bin/execlineb -W
    echo run-services svscan crash.
  '';

  dot_s6_svscan = pkgs.stdenv.mkDerivation {
    name = "dot_s6_svscan";
    src = ./.;
    installPhase = ''
      mkdir -p $out
      cp -a ${run_services_finish} $out/finish
      cp -a ${run_services_crash} $out/crash
    '';
  };

  readme = builtins.toFile "README.md" "This is an auto-generated scandir.\n";

  # This should be a list of services used below (i.e. cp -a for each).
  # scandir = [ dummy ];

  run_script = pkgs.writeScript "run-services" ''
    #! ${pkgs.stdenv.shell}
    set -e
    echo run-services is starting...
    TMP_DIR=$(${pkgs.busybox}/bin/mktemp -d -p /tmp scandir-XXXXXX)
    echo Running service directory: ''${TMP_DIR}.
    cp -a ${readme} ''${TMP_DIR}/
    echo Copying ${dummy}...
    cp -a ${dummy} ''${TMP_DIR}/dummy
    cp -a ${dot_s6_svscan} ''${TMP_DIR}/.s6-svscan
    echo Running s6-svscan...
    ${pkgs.busybox}/bin/chmod u+w -R ''${TMP_DIR}
    ${pkgs.s6}/bin/s6-svscan ''${TMP_DIR}
  '';

  maindir = pkgs.stdenv.mkDerivation {
    name = "maindir";
    src = ./.;
    installPhase = ''
      mkdir -p $out/bin
      cp ${run_script} $out/bin/run-services
    '';
  };

  services-shell = pkgs.stdenv.mkDerivation rec {
    name = "env";
    env = pkgs.buildEnv {
      name = name;
      paths = buildInputs;
    };
    buildInputs = [
      pkgs.busybox
      pkgs.execline
      pkgs.s6
      dummy
      maindir
    ];
  };

}
