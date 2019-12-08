{ lib, stdenv, fetchFromGitLab, cmake, libGLU, libGL, zlib, wxGTK
, libX11, gettext, glew, glm, cairo, curl, openssl, boost, pkgconfig
, doxygen, pcre, libpthreadstubs, libXdmcp, makeWrapper, gnome3
, gsettings-desktop-schemas, librsvg, hicolor-icon-theme, cups
, fetchpatch, kicad-libraries, lndir

, oceSupport ? false, opencascade
, withOCCT ? true, opencascade-occt
, ngspiceSupport ? true, libngspice
, scriptingSupport ? true, swig, python, pythonPackages, wxPython
, debug ? false, valgrind
, with3d ? true
}:


assert ngspiceSupport -> libngspice != null;

with lib;

# oce on aarch64 fails a test
let
  withOCC = (stdenv.isAarch64 && (withOCCT || oceSupport)) || (!stdenv.isAarch64 && withOCCT);
  withOCE = oceSupport && !stdenv.isAarch64 && !withOCC;

in
stdenv.mkDerivation rec {
  pname = "kicad-unstable";
  version = "2019-12-05";

  src = fetchFromGitLab {
    group = "kicad";
    owner = "code";
    repo = "kicad";
    rev = "65ef8c18944947c3305619032bd1aedbe8b99d64";
    sha256 = "0p0bm2yb34gqwks3qppwzgf5nylmn85psx2wwgk34yc8hs1p7yq0";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/johnbeard/kicad/commit/dfb1318a3989e3d6f9f2ac33c924ca5030ea273b.patch";
      sha256 = "00ifd3fas8lid8svzh1w67xc8kyx89qidp7gm633r014j3kjkgcd";
    })
  ];

  postPatch = ''
    substituteInPlace CMakeModules/KiCadVersion.cmake \
      --replace "unknown" ${version}
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
    ++ optionals (withOCC)
      [ "-DKICAD_USE_OCC=ON" "-DOCC_INCLUDE_DIR=${opencascade-occt}/include/opencascade" ]
    ++ optionals (debug) [
      "-DCMAKE_BUILD_TYPE=Debug"
      "-DKICAD_STDLIB_DEBUG=ON"
      "-DKICAD_USE_VALGRIND=ON"
    ]
    ;

  pythonPath =
    optionals (scriptingSupport)
    [ wxPython pythonPackages.six ];

  nativeBuildInputs =
    [ cmake doxygen pkgconfig lndir ]
    ++ optionals (scriptingSupport)
      [ pythonPackages.wrapPython makeWrapper ]
  ;

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

  doInstallCheck = (!debug);
  installCheckTarget = "test";

  dontStrip = debug;

  postInstall = ''
    mkdir -p $out/share
    lndir ${kicad-libraries.i18n}/share $out/share

    long_shit="share/kicad/template"
    mkdir -p $out/$long_shit
    ln -s ${kicad-libraries.symbols}/$long_shit/sym-lib-table $out/$long_shit
    ln -s ${kicad-libraries.footprints}/$long_shit/fp-lib-table $out/$long_shit
  '';

  makeWrapperArgs = [
    "--prefix XDG_DATA_DIRS : ${hicolor-icon-theme}/share"
    "--prefix XDG_DATA_DIRS : ${gnome3.defaultIconTheme}/share"
    "--prefix XDG_DATA_DIRS : ${wxGTK.gtk}/share/gsettings-schemas/${wxGTK.gtk.name}"
    "--prefix XDG_DATA_DIRS : ${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}"
    # wrapGAppsHook did these, as well, no idea if it matters...
    "--prefix XDG_DATA_DIRS : ${cups}/share"
    "--prefix GIO_EXTRA_MODULES : ${gnome3.dconf}/lib/gio/modules"
  ]
  ++ optionals (ngspiceSupport) [ "--prefix LD_LIBRARY_PATH : ${libngspice}/lib" ]
  # infinisil's workaround for #39493
  ++ [ "--set GDK_PIXBUF_MODULE_FILE ${librsvg}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache" ]

  # attempt at making symbol editing work
  ++ [
    "--set KICAD_TEMPLATE_DIR ${kicad-libraries.templates}/share/kicad/template"
    "--set KICAD_SYMBOL_DIR ${kicad-libraries.symbols}/share/kicad/library"
    "--set KISYSMOD ${kicad-libraries.footprints}/share/kicad/modules"
  ]
  ++ optionals (with3d) [ "--set KISYS3DMOD ${kicad-libraries.packages3d}/share/kicad/modules/packages3d" ]
  ;

  # can't add $out stuff to makeWrapperArgs...
  # wrapGAppsHook added the $out/share, though i noticed no difference without it
  preFixup =
    optionalString (scriptingSupport) '' buildPythonPath "$out $pythonPath"
    '' +
    '' wrapProgram $out/bin/kicad $makeWrapperArgs --prefix XDG_DATA_DIRS : $out/share ''
    + optionalString (scriptingSupport) '' --set PYTHONPATH "$program_PYTHONPATH"
    '' +
    '' wrapProgram $out/bin/pcbnew $makeWrapperArgs --prefix XDG_DATA_DIRS : $out/share ''
    + optionalString (scriptingSupport) '' --set PYTHONPATH "$program_PYTHONPATH"
    '' +
    '' wrapProgram $out/bin/eeschema $makeWrapperArgs --prefix XDG_DATA_DIRS : $out/share ''
    + optionalString (scriptingSupport) '' --set PYTHONPATH "$program_PYTHONPATH"
    '' +
    '' wrapProgram $out/bin/gerbview $makeWrapperArgs --prefix XDG_DATA_DIRS : $out/share ''
    + optionalString (scriptingSupport) '' --set PYTHONPATH "$program_PYTHONPATH"
    '' +
    '' wrapProgram $out/bin/pcb_calculator $makeWrapperArgs --prefix XDG_DATA_DIRS : $out/share ''
    + optionalString (scriptingSupport) '' --set PYTHONPATH "$program_PYTHONPATH"
    '' +
    '' wrapProgram $out/bin/pl_editor $makeWrapperArgs --prefix XDG_DATA_DIRS : $out/share ''
    + optionalString (scriptingSupport) '' --set PYTHONPATH "$program_PYTHONPATH"
    '' +
    '' wrapProgram $out/bin/bitmap2component $makeWrapperArgs ''
    + optionalString (scriptingSupport) '' --set PYTHONPATH "$program_PYTHONPATH"
    ''
  ;

  meta = {
    description = "Free Software EDA Suite, Nightly Development Build";
    homepage = "https://www.kicad-pcb.org/";
    license = licenses.agpl3;
    maintainers = with maintainers; [ evils kiwi berce ];
    platforms = with platforms; linux;
  };
}
