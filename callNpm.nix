{ pkgs ? import <nixpkgs> {}, name, versionSpec } :
  let
    npm2nix = pkgs.stdenv.mkDerivation {
      inherit name;
      nativeBuildInputs = [ pkgs.nodePackages.node2nix pkgs.nix ];
      phases = [ "unpackPhase" "buildPhase" "installPhase" ];
      src = pkgs.writeTextDir "node-packages.json" (''
        [ { "${name}": "${versionSpec}" } ]
      '');
      buildPhase = ''
        node2nix --nodejs-10 --input node-packages.json
      '';
      installPhase = ''
        mkdir -p "$out"
        cp *.nix "$out"
      '';
    };
  in
    (pkgs.callPackage npm2nix {})."${name}-${versionSpec}"
