{ lib
, stdenv
, fetchgit

, cmake
, libtool
, pkg-config
, wrapQtAppsHook

, sigrok
, glib
, glibmm
, boost

, qtbase
, qtsvg
, qttools
, qwt

# undocumented, found from missing in configurePhase
, libftdi1
, hidapi
, bluez
, nettle
, util-linux
, libselinux
, libsepol
, pcre
, libzip
, python3

, withDocs ? true # this only generates a PDF and HTML copy, man page is generated anyway
, asciidoctor
}:

stdenv.mkDerivation rec {
  pname = "pulseview";
  version = "136995b831c50d3261143b1183c73af55c9ba3a5";

  src = fetchgit {
    url = "git://sigrok.org/pulseview.git";
    rev = version;
    hash = "sha256-OIWEACdsrM8Zv92i4vnOU36m8id6hL2Q9O/jIMitbNQ=";
  };

  nativeBuildInputs = [
    cmake
    libtool
    pkg-config
    wrapQtAppsHook
  ] ++ lib.optionals (withDocs) [
    asciidoctor
  ];

  buildInputs = [
    sigrok.libsigrok
    sigrok.libsigrokdecode
    sigrok.libserialport

    glib
    glibmm
    boost

    qtbase
    qtsvg
    qttools
    qwt

    libftdi1
    hidapi
    bluez
    nettle
    util-linux # for "mount"
    libselinux
    libsepol
    pcre
    libzip
    python3
  ];


  postBuild = if (withDocs) then "make manual" else "";

  meta = with lib; {
    description = "Qt based logic analyzer, oscilloscope and MSO GUI for sigrok";
    homepage = "https://sigrok.org/wiki/PulseView";
    license = licenses.gpl3Plus;
    platforms = platforms.all;
    maintainers = [ maintainers.evils ];
  };
}
