{
    description = "NETGEN is an automatic 3d tetrahedral mesh generator";
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
            netgen = let
                pkgs = nixpkgsFor.${system};
                pname = "netgen";
                version = "6.2.2304";

            in pkgs.stdenv.mkDerivation {
                inherit pname version;

                src = pkgs.fetchFromGitHub {
                    owner = "NGSolve";
                    repo = "netgen";
                    rev = "v${version}";
                    sha256 = "sha256-Rd7G316oIDklVq4uo7pS+v9ZqL+oV+RtZVU6iKYJCjM=";
                };

                patches = [
                    ./regex-version.patch
                ];

                cmakeFlags = [
                    "-G Ninja"
                    "-D CMAKE_BUILD_TYPE=Release"
                    "-D USE_NATIVE_ARCH:BOOL=OFF"
                    "-D USE_OCC:BOOL=ON"
                    "-D USE_PYTHON:BOOL=ON"
                    "-D USE_GUI:BOOL=ON"
                    "-D USE_MPI:BOOL=ON"
                    "-D USE_SUPERBUILD:BOOL=OFF"
                    "-D PREFER_SYSTEM_PYBIND11:BOOL=ON"
                ];

                nativeBuildInputs = with pkgs; [
                    cmake
                    ninja
                    git
                    (python3.withPackages (ps: with ps; [
                        pybind11
                        mpi4py
                    ]))
                ];

                buildInputs = with pkgs; [
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

                meta = with pkgs.lib; {
                    homepage = "https://github.com/NGSolve/netgen";
                    description = "NETGEN is an automatic 3d tetrahedral mesh generator.";
                    license = licenses.lgpl21Only;
                    platforms = platforms.linux;
                    maintainers = [];
                    broken = pkgs.stdenv.isDarwin;
                };
            };

            default = self.packages.${system}.netgen;
        });

        devShells = forAllSystems (system: {
            netgen = let
                pkgs = nixpkgsFor.${system};
                netgen = self.packages.${system}.netgen;
                custom-python = pkgs.python3.withPackages(ps: with ps; []);

            in pkgs.mkShellNoCC {
                packages = with pkgs; [
                    netgen
                    custom-python
                ];

                shellHook = ''
                    export PYTHONPATH="${custom-python}/${pkgs.python3.sitePackages}"
                    export PYTHONPATH="$PYTHONPATH:${netgen}/${pkgs.python3.sitePackages}"
                '';
            };

            default = self.devShells.${system}.netgen;
        });

        apps = forAllSystems (system: {
            netgen = let
                pkgs = nixpkgsFor.${system};
                netgen = self.packages.${system}.netgen;

            in {
                type = "app";
                program = "${netgen}/bin/netgen";
            };

            default = self.apps.${system}.netgen;
        });

    };
}
