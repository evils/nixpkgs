{ lib, stdenv, fetchFromGitLab, cmake, libGLU, libGL, zlib, wxGTK
, libX11, gettext, glew, glm, cairo, curl, openssl, boost, pkgconfig
, doxygen, pcre, libpthreadstubs, libXdmcp, fetchpatch, lndir, callPackages

, pname ? "kicad"
, stable ? true
, versions ? { }
, oceSupport ? false, opencascade
, withOCCT ? true, opencascade-occt
, ngspiceSupport ? true, libngspice
, scriptingSupport ? true, swig, python, pythonPackages, wxPython
, debug ? false, valgrind
, with3d ? true
, withI18n ? true
}:

assert ngspiceSupport -> libngspice != null;

with lib;
let

  versionConfig = versions.${if (stable) then "kicad" else "kicad-unstable"};

  # oce on aarch64 fails a test
  withOCC = (withOCCT || (stdenv.isAarch64 && oceSupport)) && (!stdenv.isAarch64 && !oceSupport);
  withOCE = oceSupport && !stdenv.isAarch64 && !withOCC;
  kicad-libraries = callPackages ./libraries.nix versionConfig.libVersion;

in
stdenv.mkDerivation rec {

  inherit pname;
  version = "base-${versions.${if (stable) then "kicad" else "kicad-unstable"}.kicadVersion.version}";

  src = fetchFromGitLab (
    {
      group = "kicad";
      owner = "code";
      repo = "kicad";
      rev = version;
    } // versionConfig.kicadVersion.src
  );

  # quick fix for #72248
  # should be removed if a a more permanent fix is published
  patches = [
    (
      fetchpatch {
        url = "https://github.com/johnbeard/kicad/commit/dfb1318a3989e3d6f9f2ac33c924ca5030ea273b.patch";
        sha256 = "00ifd3fas8lid8svzh1w67xc8kyx89qidp7gm633r014j3kjkgcd";
      }
    )
  ];

  # tagged releases don't have "unknown"
  postPatch = optional (!stable)
  ''
    substituteInPlace CMakeModules/KiCadVersion.cmake \
      --replace "unknown" ${version}
    echo "replaced \"unknown\" with \"${version}\" in version name"
  '';

  makeFlags = optional (debug) [ "CFLAGS+=-Og" "CFLAGS+=-ggdb" ];

  cmakeFlags =
    optionals (scriptingSupport) [
      "-DKICAD_SCRIPTING=ON"
      "-DKICAD_SCRIPTING_MODULES=ON"
      "-DKICAD_SCRIPTING_PYTHON3=ON"
      "-DKICAD_SCRIPTING_WXPYTHON_PHOENIX=ON"
    ]
    ++ optional (!scriptingSupport)
      "-DKICAD_SCRIPTING=OFF"
    ++ optional (ngspiceSupport) "-DKICAD_SPICE=ON"
    ++ optionals (withOCE)
      [ "-DKICAD_USE_OCE=ON" "-DOCE_DIR=${opencascade}" ]
    ++ optionals (withOCC) [
      "-DKICAD_USE_OCC=ON"
      # this line is redundant on unstable...
      # maybe may be removed on a later release
      "-DKICAD_USE_OCE=OFF"
      "-DOCC_INCLUDE_DIR=${opencascade-occt}/include/opencascade"
    ]
    ++ optionals (debug) [
      "-DCMAKE_BUILD_TYPE=Debug"
      "-DKICAD_STDLIB_DEBUG=ON"
      "-DKICAD_USE_VALGRIND=ON"
    ]
  ;

  pythonPath =
    optionals (scriptingSupport)
      [ wxPython pythonPackages.six ];

  nativeBuildInputs = [ cmake doxygen pkgconfig lndir ];

  buildInputs = [
    libGLU libGL zlib libX11 wxGTK pcre libXdmcp gettext
    glew glm libpthreadstubs cairo curl openssl boost
  ]
  ++ optionals (scriptingSupport) [ swig python wxPython ]
  ++ optional (ngspiceSupport) libngspice
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
    lndir ${kicad-libraries.i18n}/share $out/share
  '';

  meta = {
    description = "just the built source without the libraries";
    longDescription = ''
      just the build products, optionally with the i18n linked in
      the libraries are passed via an env var in the wrapper, default.nix
    '';
    homepage = "https://www.kicad-pcb.org/";
    license = licenses.agpl3;
    maintainers = with maintainers; [ evils kiwi berce ];
    platforms = with platforms; linux;
  };
}
