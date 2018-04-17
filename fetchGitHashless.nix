{ pkgs ? import <nixpkgs> {}, args } :
  pkgs.stdenv.lib.overrideDerivation
    # Use a dummy hash, to appease fetchgit's assertions
    (pkgs.fetchgit (args // { sha256 = pkgs.stdenv.hashString "sha256" args.url; }))
    # Remove the hash-checking
    (old: {
      outputHash     = null;
      outputHashAlgo = null;
      outputHashMode = null;
      sha256         = null;
    })
