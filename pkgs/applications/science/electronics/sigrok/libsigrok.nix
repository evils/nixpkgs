{ lib
, stdenv
, fetchgit

# NativeBuildInputs
, autoconf
, automake
, pkg-config
, libtool
, check
, python3

# buildInputs
, libzip
, glib
, glibmm
, libusb1
, libftdi1
, libserialport
, hidapi
, sigrok

# found missing by configurePhase
, zlib # not actually found by providing it
, nettle
, libtirpc # claims to be Sun RPC but only detected as TI-RPC and RPC
, libieee1284
, bluez
#, libgpib # missing
#, librevisa # missing, neither pyvisa nor pyvisa-py seem like an adequate substitute

# optional NativeBuildInputs
, withDocs ? true
, doxygen
, graphviz
, withCppBindings ? true
, autoconf-archive
, withPythonBindings ? true # requires patch to python-install make target
, swig
, withRubyBindings ? false # error: stray '@' in program and many more compilation errors
, ruby
, rubyPackages
, withJavaBindings ? true
, openjdk
}:

stdenv.mkDerivation rec {
  pname = "libsigrok";
  version = "0dea0243dc7c7320d73266845908c85addbd0a78";

  src = fetchgit {
    url = "git://sigrok.org/libsigrok.git";
    rev = version;
    hash = "sha256-MG66QrvukAA1zQDAgVxQMB9J72/dXuTPRFnB+6cFpv0=";
  };

  patches = [ ./libsigrok-Makefile.patch ];

  nativeBuildInputs = [
    autoconf
    automake
    check
    libtool
    pkg-config
    python3
  ] ++ lib.optionals (withDocs) [
    doxygen
    graphviz
  ] ++ lib.optionals ( # C++ bindings required for the other bindings
      withCppBindings
      || withPythonBindings
      || withRubyBindings
      || withJavaBindings) [
    doxygen
    autoconf-archive
  ] ++ lib.optionals (withPythonBindings) [
    python3.pkgs.setuptools
    python3.pkgs.pygobject3
    python3.pkgs.numpy
    swig
    graphviz
  ] ++ lib.optionals (withRubyBindings) [
    ruby
    swig
  ] ++ lib.optionals (withRubyBindings && withDocs) [
    rubyPackages.yard
  ] ++ lib.optionals (withJavaBindings) [
    openjdk
    swig
  ];

  buildInputs = [
    libzip
    glib
    libusb1
    libftdi1
    libserialport
    glibmm
    hidapi

    zlib
    nettle
    libtirpc
    # libgpib
    # librevisa
  ] ++ lib.optionals (stdenv.isLinux) [
    libieee1284
    bluez
  ];


  preConfigure = "./autogen.sh";

  postInstall = ''
    mkdir -p $out/share/sigrok-firmware
    ln -s ${sigrok.sigrok-firmware}/share/sigrok-firmware/* $out/share/sigrok-firmware
    ln -s ${sigrok.sigrok-firmware-fx2lafw}/share/sigrok-firmware/* $out/share/sigrok-firmware
  '';

  doCheck = true;

  meta = with lib; {
    description = "Core library of the sigrok signal analysis software suite";
    homepage = "https://sigrok.org/wiki/Libsigrok";
    license = licenses.gpl3Plus;
    platforms = platforms.all;
    maintainers = [ maintainers.evils ];
  };
}
