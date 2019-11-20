# `postBuild` is a fairly hacky way of accommodating one-off fixes
{ pkgs ? import <nixpkgs> {}, name, package, packageLock, postBuild ? "" } :
    pkgs.stdenv.mkDerivation {
      name = "node2nix-${name}";
      nativeBuildInputs = [ pkgs.nodePackages.node2nix pkgs.nix ];
      phases = [ "buildPhase" "installPhase" ];
      srcs = [ package packageLock ];
      buildPhase = ''
        cp ${package} package.json
        cp ${packageLock} package-lock.json
        node2nix --development --nodejs-10 --input package.json --lock package-lock.json
        ${postBuild}
      '';
      installPhase = ''
        mkdir -p "$out"
        cp package.json package-lock.json *.nix "$out"
      '';
    }
