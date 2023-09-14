{
    description = "OpenFOAM is a free, open source CFD software.";
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
            openfoam-org = let
                pkgs = nixpkgsFor.${system};
                realname = "OpenFOAM";
                pname = "openfoam-org";
                major-version = "11";
                revision = "20230907";
                version = "${major-version}.${revision}";

            in pkgs.stdenv.mkDerivation {
                inherit pname version major-version;

                src = pkgs.fetchFromGitHub {
                    owner = "OpenFOAM";
                    repo = "${realname}-${major-version}";
                    rev = "${revision}";
                    sha256 = "sha256-oT9NkQR/KGQYPX5gNuebMZFz+hxG5vp4fownQMkX5r0=";
                };

                nativeBuildInputs = with pkgs; [ bash m4 flex bison ];

                buildInputs = with pkgs; [ fftw mpi scotch boost cgal zlib ];

                postPatch = ''
                    substituteInPlace etc/bashrc \
                        --replace '[ "$BASH" -o "$ZSH_NAME" ] && \' '#' \
                        --replace 'export FOAM_INST_DIR=$(cd $(dirname ${"$"}{BASH_SOURCE:-$0})/../.. && pwd -P) || \' '#' \
                        --replace 'export FOAM_INST_DIR=$HOME/$WM_PROJECT' '# __inst_dir_placeholder__'

                    patchShebangs Allwmake
                    patchShebangs etc
                    patchShebangs wmake
                    patchShebangs applications
                    patchShebangs bin
                '';

                configurePhase = ''
                    export FOAM_INST_DIR=$NIX_BUILD_TOP/source
                    export WM_PROJECT_DIR=$FOAM_INST_DIR/${realname}-${major-version}
                    mkdir $WM_PROJECT_DIR

                    mv $(find $FOAM_INST_DIR/ -maxdepth 1 -not -path $WM_PROJECT_DIR -not -path $FOAM_INST_DIR/) \
                        $WM_PROJECT_DIR/

                    set +e
                    . $WM_PROJECT_DIR/etc/bashrc
                    set -e
                '';

                buildPhase = ''
                    sh $WM_PROJECT_DIR/Allwmake -j$CORES
                    wclean all
                    wmakeLnIncludeAll
                '';

                installPhase = ''
                    mkdir -p $out/${realname}-${major-version}

                    substituteInPlace $WM_PROJECT_DIR/etc/bashrc \
                        --replace '# __inst_dir_placeholder__' "export FOAM_INST_DIR=$out"

                    cp -Ra $WM_PROJECT_DIR/* $out/${realname}-${major-version}
                '';

                meta = with pkgs.lib; {
                    homepage = "https://www.openfoam.org/";
                    description = "OpenFOAM is a free, open source CFD software released and developed by OpenFOAM Foundation";
                    license = licenses.gpl3;
                    platforms = platforms.linux;
                    maintainers = [];
                    broken = pkgs.stdenv.isDarwin;
                };
            };

            default = self.packages.${system}.openfoam-org;
        });

        devShells = forAllSystems (system: {
            openfoam-org = let
                pkgs = nixpkgsFor.${system};
                openfoam-org = self.packages.${system}.openfoam-org;

            in pkgs.mkShellNoCC {
                packages = [
                    pkgs.mpi
                    openfoam-org
                ];

                shellHook = ''
                    . ${openfoam-org}/OpenFOAM-${openfoam-org.major-version}/etc/bashrc
                '';
            };

            default = self.devShells.${system}.openfoam-org;
        });
    };
}
