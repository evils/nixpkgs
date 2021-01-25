{ lib
, stdenv
, cmake
, libGLU
, libGL
, zlib
, wxGTK
, libX11
, gettext
, glew
, glm
, cairo
, curl
, openssl
, boost
, pkg-config
, doxygen
, graphviz
, pcre
, libpthreadstubs
, libXdmcp
, lndir

, util-linux
, libselinux
, libsepol
, libthai
, libdatrie
, libxkbcommon
, epoxy
, dbus_daemon
, at_spi2_core
, xlibs

, swig
, python
, wxPython
, opencascade
, opencascade-occt
, libngspice
, valgrind

, stable
, baseName
, kicadSrc
, kicadVersion
, i18n
, withOCE
, withOCC
, withNgspice
, withScripting
, debug
, withI18n
, withWayland
}:

assert lib.asserts.assertMsg (!(withOCE && stdenv.isAarch64)) "OCE fails a test on Aarch64";
assert lib.asserts.assertMsg (!(withOCC && withOCE))
  "Only one of OCC and OCE may be enabled";
let
  inherit (lib) optional optionals optionalString;
in
stdenv.mkDerivation rec {
  pname = "kicad-base";
  version = if (stable) then kicadVersion else builtins.substring 0 10 src.rev;

  src = kicadSrc;

  # tagged releases don't have "unknown"
  # kicad nightlies use git describe --dirty
  # nix removes .git, so its approximated here
  postPatch = ''
    substituteInPlace CMakeModules/KiCadVersion.cmake \
      --replace "unknown" "${builtins.substring 0 10 src.rev}"
  ''
  + optionalString (withWayland) ''
    substituteInPlace kicad/kicad.cpp \
      --replace "x11" "wayland"
    substituteInPlace common/single_top.cpp \
      --replace "x11" "wayland"
    substituteInPlace  libs/kiplatform/gtk/environment.cpp \
      --replace "x11" "wayland"
  '';

  makeFlags = optional (debug) [ "CFLAGS+=-Og" "CFLAGS+=-ggdb" ];

  cmakeFlags = optionals (withScripting) [
      "-DKICAD_SCRIPTING=ON"
      "-DKICAD_SCRIPTING_MODULES=ON"
      "-DKICAD_SCRIPTING_PYTHON3=ON"
      "-DKICAD_SCRIPTING_WXPYTHON_PHOENIX=ON"
    ]
    ++ optional (!withScripting)
      "-DKICAD_SCRIPTING=OFF"
    ++ optional (withNgspice) "-DKICAD_SPICE=ON"
    ++ optional (!withOCE) "-DKICAD_USE_OCE=OFF"
    ++ optional (!withOCC) "-DKICAD_USE_OCC=OFF"
    ++ optionals (withOCE) [
      "-DKICAD_USE_OCE=ON"
      "-DOCE_DIR=${opencascade}"
    ]
    ++ optionals (withOCC) [
      "-DKICAD_USE_OCC=ON"
      "-DOCC_INCLUDE_DIR=${opencascade-occt}/include/opencascade"
    ]
    ++ optionals (debug) [
      "-DCMAKE_BUILD_TYPE=Debug"
      "-DKICAD_STDLIB_DEBUG=ON"
      "-DKICAD_USE_VALGRIND=ON"
      "-DKICAD_SANITIZE=ON"
    ]
    ++ optionals (withWayland) [
      "-DKICAD_USE_EGL=ON"
    ]
  ;

  nativeBuildInputs = [
    cmake
    doxygen
    graphviz
    pkg-config
    lndir
  ];

  buildInputs = [
    libGLU
    libGL
    zlib
    libX11
    wxGTK
    wxGTK.gtk
    pcre
    libXdmcp
    gettext
    glew
    glm
    libpthreadstubs
    cairo
    curl
    openssl
    boost

    util-linux
    libselinux
    libsepol
    libthai
    libdatrie
    libxkbcommon
    epoxy
    dbus_daemon.dev
    at_spi2_core
    xlibs.libXtst
  ]
  ++ optionals (withScripting) [ swig python wxPython ]
  ++ optional (withNgspice) libngspice
  ++ optional (withOCE) opencascade
  ++ optional (withOCC) opencascade-occt
  ++ optional (debug) valgrind
  ;

  # debug builds fail all but the python test
  # 5.1.x fails the eeschema test
  doInstallCheck = !debug && !stable;
  installCheckTarget = "test";

  dontStrip = debug;

  postInstall = optional (withI18n) ''
    mkdir -p $out/share
    lndir ${i18n}/share $out/share
  '';

  meta = {
    description = "Just the built source without the libraries";
    longDescription = ''
      Just the build products, optionally with the i18n linked in
      the libraries are passed via an env var in the wrapper, default.nix
    '';
    homepage = "https://www.kicad-pcb.org/";
    license = lib.licenses.agpl3;
    platforms = lib.platforms.all;
  };
}
