{
    description = "Base description.";
    nixConfig.bash-prompt = "\[nix-develop\]$ ";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    outputs = { self, nixpkgs, ... }:
    let
        systems = [ "x86_64-linux" ];
        forAllSystems = nixpkgs.lib.genAttrs systems;
        nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

    in {
        packages = forAllSystems (system: {
            example = let
                pkgs = nixpkgsFor.${system};
                pname = "example";
                version = "0.0";

            in pkgs.stdenv.mkDerivation {
                inherit pname version;

                src = pkgs.fetchFromGitHub {
                    owner = "example-owner";
                    repo = "example-repo";
                    rev = "v${version}";
                    sha256 = "";
                };

                nativeBuildInputs = with pkgs; [ bash ];

                buildInputs = with pkgs; [ boost ];

                patches = [];

                postPatch = ''
                '';

                configurePhase = ''
                '';

                buildPhase = ''
                '';

                installPhase = ''
                '';

                meta = with pkgs.lib; {
                    homepage = "https://www.example.org/";
                    description = "Short description.";
                    license = licenses.gpl3;
                    platforms = platforms.linux;
                    maintainers = [];
                    broken = true;
                };
            };

            default = self.packages.${system}.example;
        });

        devShells = forAllSystems (system: {
            example = let
                pkgs = nixpkgsFor.${system};
                example = self.packages.${system}.example;

            in pkgs.mkShellNoCC {
                packages = [
                    pkgs.bash
                    example
                ];

                shellHook = ''
                '';
            };

            default = self.devShells.${system}.example;
        });
    };
}
