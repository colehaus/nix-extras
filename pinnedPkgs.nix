# `specFile` ought to be generated with `nix-prefetch-git ${url}`
{ fetchFromGitHub ? (import <nixpkgs> {}).fetchFromGitHub, specFile, opts } :
  let
    nixpkgs =
      fetchFromGitHub {
        owner = "NixOS";
        repo  = "nixpkgs";
        inherit (builtins.fromJSON (builtins.readFile specFile)) rev sha256;
      };
  in
    import nixpkgs opts
