# `postBuild` is a fairly hacky way of accommodating one-off fixes
{ pkgs ? import <nixpkgs> {}, name, package, packageLock, postBuild ? "" } :
  let
    packageJson = pkgs.writeTextDir "package.json" (builtins.readFile package);
    packageLockJson = pkgs.writeTextDir "package-lock.json" (builtins.readFile packageLock);
    node2nix = pkgs.stdenv.mkDerivation {
      name = "node2nix-${name}";
      nativeBuildInputs = [ pkgs.nodePackages.node2nix pkgs.nix ];
      phases = [ "buildPhase" "installPhase" ];
      srcs = [ packageJson packageLockJson ];
      # We need the temporary directory so that `node2nix`'s relative paths are correct
      buildPhase = ''
        TMP=$(mktemp -d)
        cd $TMP
        node2nix --development --nodejs-10 --input ${packageJson}/package.json --lock ${packageLockJson}/package-lock.json
        ${postBuild}
      '';
      installPhase = ''
        mkdir -p "$out"
        cp *.nix "$out"
      '';
    };
  in
    pkgs.callPackage node2nix {}
