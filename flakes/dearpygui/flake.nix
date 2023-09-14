{
    description = "Dear PyGui: A fast and powerful Graphical User Interface Toolkit for Python with minimal dependencies";
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
            dearpygui = let
                pkgs = nixpkgsFor.${system};
                pname = "dearpygui";
                version = "1.10.0";

            in pkgs.python3.pkgs.buildPythonPackage {
                inherit pname version;

                src = pkgs.fetchFromGitHub {
                    owner = "hoffstadt";
                    repo = "DearPyGui";
                    rev = "v${version}";
                    fetchSubmodules = true;
                    sha256 = "sha256-36GAGfvHZyNZe/Z7o3VrCCwApkZpJ+r2E8+1Hy32G5Q=";
                };

                cmakeFlags = [
                    "-DMVDIST_ONLY=True"
                ];

                postConfigure = ''
                    cd $cmakeDir
                    mv build cmake-build-local
                '';

                nativeBuildInputs = with pkgs; [
                    pkg-config
                    cmake
                ];

                buildInputs = with pkgs; [
                    xorg.libX11.dev
                    xorg.libXrandr.dev
                    xorg.libXinerama.dev
                    xorg.libXcursor.dev
                    xorg.xinput
                    xorg.libXi.dev
                    xorg.libXext
                    libxcrypt

                    glfw
                    glew
                ];

                dontUseSetuptoolsCheck = true;

                pythonImportsCheck = [
                    "dearpygui"
                ];

                meta = with pkgs.lib; {
                    homepage = "https://dearpygui.readthedocs.io/en/";
                    description = "Dear PyGui: A fast and powerful Graphical User Interface Toolkit for Python with minimal dependencies.";
                    license = licenses.mit;
                    platforms = platforms.linux;
                    maintainers = [];
                    broken = pkgs.stdenv.isDarwin;
                };
            };

            default = self.packages.${system}.dearpygui;
        });

        devShells = forAllSystems (system: {
            dearpygui = let
                pkgs = nixpkgsFor.${system};
                custom-python = pkgs.python3.withPackages(ps: with ps; [
                    self.packages.${system}.dearpygui
                ]);

            in pkgs.mkShellNoCC {
                packages = with pkgs; [
                    custom-python
                ];

                shellHook = ''
                    export PYTHONPATH=${custom-python}/${custom-python.sitePackages}
                '';
            };

            default = self.devShells.${system}.dearpygui;
        });
    };
}
