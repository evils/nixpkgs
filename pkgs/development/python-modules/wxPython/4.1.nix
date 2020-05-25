{ lib
, stdenv
, openglSupport ? true

# build time deps
, fetchPypi
, buildPythonPackage
, which
, pkgconfig

# runtime deps
# listed by them
, python
, freeglut
, gstreamer
, wxGTK
, libpng
, libtiff
, libjpeg
, libnotify
, SDL2
, xorg		# libxtst, libsm

# not listed by them
, libX11
, pyopengl
, gst-plugins-base
, requests
, doxygen
, cairo
, ncurses
, pango
, pathlib2

, libGLU
}:

buildPythonPackage rec {
  pname = "wxPython";
  version = "4.1.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "12x4ci5q7qni4rkfiq6lnpn1fk8b0sfc6dck5wyxkj2sfp5pa91f";
  };

  # https://github.com/NixOS/nixpkgs/issues/75759
  # https://github.com/wxWidgets/Phoenix/issues/1316
  doCheck = false;

  nativeBuildInputs = [ pkgconfig which doxygen wxGTK ];

  buildInputs = [
    freeglut
    gstreamer
    wxGTK.gtk
    libpng
    libtiff
    libjpeg
    libnotify
    SDL2
    xorg.libSM
    xorg.libXtst

    # not listed by them
    gst-plugins-base ncurses
    requests libX11
    pathlib2

    libGLU
  ]
    ++ lib.optional openglSupport pyopengl;

  hardeningDisable = [ "format" ];

  DOXYGEN = "${doxygen}/bin/doxygen";

  preConfigure = lib.optionalString (!stdenv.isDarwin) ''
    substituteInPlace wx/lib/wxcairo/wx_pycairo.py \
      --replace 'cairoLib = None' 'cairoLib = ctypes.CDLL("${cairo}/lib/libcairo.so")'
    substituteInPlace wx/lib/wxcairo/wx_pycairo.py \
      --replace '_dlls = dict()' '_dlls = {k: ctypes.CDLL(v) for k, v in [
        ("gdk",        "${wxGTK.gtk}/lib/libgtk-x11-3.0.so"),
        ("pangocairo", "${pango.out}/lib/libpangocairo-1.0.so"),
        ("appsvc",     None)
      ]}'

    # https://github.com/wxWidgets/Phoenix/pull/1584
    substituteInPlace build.py --replace "os.environ['PYTHONPATH'] = phoenixDir()" \
      "os.environ['PYTHONPATH'] = os.environ['PYTHONPATH'] + os.pathsep + phoenixDir()"
  '';

  buildPhase = ''
    ${python.interpreter} build.py -v build
  '';

  installPhase = ''
    ${python.interpreter} setup.py install --skip-build --prefix=$out
    wrapPythonPrograms
  '';

  passthru = { inherit wxGTK openglSupport; };

  meta = with lib; {
    description = "Cross platform GUI toolkit for Python, Phoenix version";
    homepage = "http://wxpython.org/";
    license = licenses.wxWindows;
    maintainers = [ maintainers.evils ];
  };

}
