{ lib
, stdenv
, fetchFromGitHub

, cmake
, libtool
, pkg-config
, wrapQtAppsHook

, sigrok
, glib
, glibmm
, boost
, python3

, qtbase
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

, withDocs ? true # this only generates a PDF and HTML copy, man page is generated anyway
, asciidoctor
}:

stdenv.mkDerivation rec {
  pname = "smuview";
  version = "a8e3784a5c42f22a66f8423131757ce0417db8b0";

  src = fetchFromGitHub {
    owner = "KnarfS";
    repo = pname;
    rev = version;
    hash = "sha256-pjhQ2qUEWc8dx0KyH9XH9nbxvQPr3qxBUi+90CX+Ej4=";
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
    sigrok.libserialport

    glib
    glibmm
    python3
    boost

    qtbase
    qwt

    # not documented, found from configurePhase failures to find
    libftdi1
    hidapi
    bluez
    nettle
    util-linux # for "mount"
    libselinux
    libsepol
    pcre
    libzip
  ];


  postBuild = if (withDocs) then "make manual" else "";

  meta = with lib; {
    description = "SmuView is a GUI for sigrok that supports power supplies, electronic loads, etc";
    homepage = "https://github.com/knarfS/smuview";
    license = licenses.gpl3Plus;
    platforms = platforms.all;
    maintainers = [ maintainers.evils ];
  };
}
