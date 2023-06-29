{
    lib, stdenv, fetchFromGitHub,
    cmake, ninja, git,
    zlib, tcl, tk, mpi, opencascade-occt, python3, libGL, libGLU, libXmu, metis
}:
let
    pname = "netgen";
    version = "6.2.2302";
in
stdenv.mkDerivation {
    name = "${pname}-${version}";

    src = fetchFromGitHub {
        owner = "NGSolve";
        repo = "netgen";
        rev = "v${version}";
        sha256 = "sha256-1D741jwgjBylXoNDDgrbeKszYn9Vxmd7nKj1xCgCIak=";
    };

    meta = with lib; {
        homepage = "https://github.com/NGSolve/netgen";
        description = "NETGEN is an automatic 3d tetrahedral mesh generator";
        license = licenses.lgpl21Only;
        platforms = platforms.linux;
        maintainers = [];
        inherit version;
        broken = false;
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
        (python3.withPackages (ps: with ps; [
            pybind11
            mpi4py
        ]))
    ];
}
