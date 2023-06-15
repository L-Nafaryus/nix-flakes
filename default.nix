{
    system ? builtins.currentSystem,
    pkgs ? import <nixpkgs> { inherit system; }
}:
rec {
    netgen = pkgs.callPackage ./pkgs/netgen {};

    openfoam-com = pkgs.callPackage ./pkgs/openfoam-com {};

    dearpygui = pkgs.callPackage ./pkgs/dearpygui {};
}
