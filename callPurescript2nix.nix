{pkgs ? import <nixpkgs> {}, name, src, doCheck ? false } :
let
  bowerDeps = pkgs.callPackage ./callBower2nix.nix {
    inherit name;
    src = "${src}/bower.json";
  };
  npmDeps = pkgs.callPackage ./callNode2nix.nix {
    inherit name;
    src = "${src}/package.json";
  };
in
  pkgs.stdenv.mkDerivation {
    inherit name;
    inherit doCheck;
    setSourceRoot = ''
      sourceRoot=$(pwd)
    '';
    srcs = [ "${src}/src" "${src}/test" "${src}/bower.json" ];
    nativeBuildInputs = [
      pkgs.nodePackages.pulp
      pkgs.purescript
    ] ++ pkgs.stdenv.lib.optionals doCheck [npmDeps.shell.nodeDependencies pkgs.nodejs];
    phases = [ "unpackPhase" "configurePhase" "buildPhase" "checkPhase" "fixupPhase" ];
    preUnpack = ''
      unpackCmdHooks+=(_cpFile)
      _cpFile() {
        local fn="$1"
        cp -p --reflink=auto -- "$fn" "$(stripHash "$fn")"
      }
    '';
    configurePhase = ''
      mkdir -p bower_components
      for hash in "${bowerDeps}"/packages/*; do
        for version in "$hash"/*; do
          cp -r "$version" bower_components/purescript-$(basename "$hash")
        done
      done
    '';
    buildPhase = ''
      pulp build --build-path "$out"
    '';
    checkPhase = ''
      pulp test
    '';
  }
