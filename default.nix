{
    system ? builtins.currentSystem,
    pkgs ? import <nixpkgs> { inherit system; }
}:
rec {
    netgen = pkgs.callPackage ./pkgs/netgen {};

    # openfoam-org = pkgs.callPackage ./pkgs/openfoam-org {};
}
