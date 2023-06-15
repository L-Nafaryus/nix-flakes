{
    pkgs ? import <nixpkgs> {}
}:
with pkgs;
let
    pkg = pkgs.callPackage ./default.nix {};
in mkShell {
    buildInputs = [
        pkg

        python3
    ];
}
