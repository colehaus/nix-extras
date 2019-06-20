# TODO: Infer `npm` from `package.json`. Doesn't work ATM due to error about string "cannot refer to other paths" when using `builtins.pathExists`.
{pkgs ? import <nixpkgs> {}, name, src, executable, npm ? false, doCheck ? false } :
let
  bowerNix = pkgs.callPackage ./callBower2nix.nix {
    inherit name;
    src = src + "/bower.json";
  };
  bowerDeps = pkgs.callPackage bowerNix {};
  npmNix = pkgs.callPackage ./callNode2nix.nix {
    inherit name;
    package = src + "/package.json";
    packageLock = src + "/package-lock.json";
  };
  npmDeps = pkgs.callPackage npmNix {};
in
  pkgs.stdenv.mkDerivation {
    inherit name;
    inherit doCheck;
    setSourceRoot = ''
      sourceRoot=$(pwd)
    '';
    srcs =
      [ (src + "/src") (src + "/test") (src + "/bower.json") ] ++
      pkgs.stdenv.lib.optionals npm [ (src + "/package.json") (src + "/package-lock.json") ] ;
    nativeBuildInputs = [
      pkgs.nodePackages.pulp
      pkgs.purescript
      bowerDeps
      bowerNix
    ] ++
    pkgs.stdenv.lib.optionals npm [ npmDeps.shell.nodeDependencies npmNix ] ++
    pkgs.stdenv.lib.optionals doCheck [ pkgs.nodejs ];
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
    buildPhase = if executable && npm then ''
      export NODE_PATH=${npmDeps.shell.nodeDependencies}/lib/node_modules
      pulp browserify --optimise --to "$out"/"$name".js
    '' else if executable && !npm then ''
      pulp browserify --optimise --to "$out"/"$name".js
    '' else ''
      pulp build --build-path "$out"
    '';
    checkPhase = ''
      pulp test
    '';
  }
