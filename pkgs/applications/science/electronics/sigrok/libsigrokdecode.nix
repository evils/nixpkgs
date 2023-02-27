{ lib
, stdenv
, fetchgit

, autoconf
, automake
, check
, libtool
, pkg-config
, python3

, glib

, withDocs ? true
, doxygen
, graphviz
}:

stdenv.mkDerivation rec {
  pname = "libsigrokdecode";
  version = "73cb5461acdbd007f4aa9e81385940fad6607696";

  src = fetchgit {
    url = "git://sigrok.org/libsigrokdecode.git";
    rev = version;
    hash = "sha256-BYF5RP4FbwI9wiNZ566+emaVpIvt072qCw77tOC8ksQ=";
  };

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
  ];

  buildInputs = [
    glib
  ];


  preConfigure = "./autogen.sh";

  doCheck = true;

  meta = with lib; {
    description = "Protocol decoding library for the sigrok signal analysis software suite";
    homepage = "https://www.sigrok.org/wiki/Libsigrokdecode";
    license = licenses.gpl3Plus;
    platforms = platforms.all;
    maintainers = [ maintainers.evils ];
  };
}
