{
    description = "Dear PyGui: A fast and powerful Graphical User Interface Toolkit for Python with minimal dependencies";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { self, nixpkgs, flake-utils, ... }:
        flake-utils.lib.eachDefaultSystem (system:
            let
                pkgs = import nixpkgs { inherit system; };
                dearpygui = pkgs.callPackage ./default.nix {};
            in rec {
                defaultPackage = dearpygui;

                defaultApp = flake-utils.lib.mkApp {
                    drv = defaultPackage;
                };

                devShell = with pkgs; mkShell {
                    buildInputs = [
                        python3.withPackages(ps: with ps; [
                            dearpygui
                        ])
                    ];
                };
            }
        );
}
