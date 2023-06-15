{
    lib, stdenv, fetchFromGitHub,
    pkg-config, cmake, xorg, glfw, glew, libxcrypt, python3
}:
with python3.pkgs; buildPythonPackage rec {
    name = "dearpygui";
    version = "1.9.1";

    meta = {
        maintainers = [];
        license = lib.licenses.mit;
        description = "Dear PyGui: A fast and powerful Graphical User Interface Toolkit for Python with minimal dependencies";
        homepage = "https://dearpygui.readthedocs.io/en/";
        platforms = lib.platforms.linux;
        inherit version;
    };

    src = fetchFromGitHub {
        owner = "hoffstadt";
        repo = "DearPyGui";
        rev = "v${version}";
        fetchSubmodules = true;
        sha256 = "sha256-XN1RS6DN79VNAhVrVw0iqMxFz/u2dn6UtZEugjkCsDs=";
    };

    cmakeFlags = [
        "-DMVDIST_ONLY=True"
    ];

    postConfigure = ''
        cd $cmakeDir
        mv build cmake-build-local
    '';

    nativeBuildInputs = [
        pkg-config
        cmake
    ];

    buildInputs = [
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
}
