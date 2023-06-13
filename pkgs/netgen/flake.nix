{
    description = "NETGEN is an automatic 3d tetrahedral mesh generator";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { self, nixpkgs, flake-utils, ... }:
        flake-utils.lib.eachDefaultSystem (system:
            let
                pkgs = import nixpkgs { inherit system; };
                netgen = pkgs.callPackage ./default.nix {};
            in rec {
                defaultPackage = netgen;
                defaultApp = flake-utils.lib.mkApp {
                    drv = defaultPackage;
                };
                devShell = with pkgs; mkShell {
                    buildInputs = [
                        netgen
                        zlib
                        tcl
                        tk
                        mpi
                        opencascade-occt
                        libGL
                        libGLU
                        xorg.libXmu
                        metis
                    ];
                };
            }
        );
}
