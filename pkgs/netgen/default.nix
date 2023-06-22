{
    lib, stdenv, fetchFromGitHub,
    cmake, ninja, git,
    zlib, tcl, tk, mpi, opencascade-occt, python3, libGL, libGLU, libXmu, metis
}:
stdenv.mkDerivation rec {
    name = "netgen";
    version = "6.2.2302";

    src = fetchFromGitHub {
        owner = "NGSolve";
        repo = "netgen";
        rev = "v${version}";
        sha256 = "sha256-1D741jwgjBylXoNDDgrbeKszYn9Vxmd7nKj1xCgCIak=";
        fetchSubmodules = true;
    };

    meta = with lib; {
        homepage = "https://github.com/NGSolve/netgen";
        description = "NETGEN is an automatic 3d tetrahedral mesh generator";
        license = licenses.lgpl21Only;
        platforms = platforms.linux;
        maintainers = [];
        inherit version;
        broken = true;
    };

    cmakeFlags = [
        "-G Ninja"
        "-D CMAKE_BUILD_TYPE=Release"
        "-D NG_INSTALL_DIR_INCLUDE:FILEPATH=include/netgen"
        "-D NG_INSTALL_DIR_BIN=bin"
        "-D NG_INSTALL_DIR_LIB=lib"
        "-D NG_INSTALL_DIR_CMAKE:FILEPATH=lib/cmake/netgen"
        "-D NG_INSTALL_DIR_RES=share"
        "-D OCC_INCLUDE_DIR:FILEPATH=include/opencascade"
        "-D OCC_LIBRARY_DIR:FILEPATH=lib"
        "-D USE_NATIVE_ARCH:BOOL=OFF"
        "-D USE_OCC:BOOL=ON"
        "-D USE_PYTHON:BOOL=ON"
        "-D USE_GUI:BOOL=ON"
        "-D USE_MPI:BOOL=ON"
        "-D USE_SUPERBUILD:BOOL=OFF"
        "-D DYNAMIC_LINK_PYTHON:BOOL=OFF"
        "-D NETGEN_VERSION_GIT=v${version}-0-0"
    ];

    nativeBuildInputs = [
        cmake
        ninja
        git
    ];

    buildInputs = [
        zlib
        tcl
        tk
        mpi
        opencascade-occt
        libGL
        libGLU
        libXmu
        metis
    ];

    propagatedBuildInputs = [
        (python3.withPackages (ps: with ps; [ pybind11 mpi4py ]))
    ];
}
