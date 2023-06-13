{
    description = "OpenFOAM is a free, open source CFD software released and developed by OpenCFD Ltd";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { self, nixpkgs, flake-utils, ... }:
        flake-utils.lib.eachDefaultSystem (system:
            let
                pkgs = import nixpkgs { inherit system; };
                openfoam-com = pkgs.callPackage ./default.nix {};
            in rec {
                defaultPackage = openfoam-com;

                defaultApp = flake-utils.lib.mkApp {
                    drv = defaultPackage;
                };

                devShell = with pkgs; mkShell {
                    buildInputs = [
                        openfoam-com
                        fftw
                        mpi
                        scotch
                        boost
                        cgal
                        zlib
                    ];
                };
            }
        );
}
