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
            in rec {
                defaultPackage = pkgs.callPackage ./default.nix {};

                defaultApp = flake-utils.lib.mkApp {
                    drv = defaultPackage;
                };

                devShells.default = import ./shell.nix { inherit pkgs; };
            }
        );
}
