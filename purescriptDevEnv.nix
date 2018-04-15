{ pkgs ? import <nixpkgs> {} }:
  pkgs.stdenv.mkDerivation {
    name = "env";
    buildInputs = [
      pkgs.git
      pkgs.nodejs
      pkgs.nodePackages.bower
      pkgs.nodePackages.pulp
      pkgs.purescript
    ];
  }
