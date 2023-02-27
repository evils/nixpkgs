{ lib
, stdenv
, fetchgit

, autoconf
, automake
, libtool
, pkg-config
, python3

, sigrok
, glib

, withDocs ? true
, doxygen
, graphviz
}:

stdenv.mkDerivation rec {
  pname = "sigrok-cli";
  version = "527dd7262e49dd051ff554401f9cb21c2c9006dd";

  src = fetchgit {
    url = "git://sigrok.org/sigrok-cli.git";
    rev = version;
    hash = "sha256-kgin6U1Aeo3ixPHYZw3mjC4i/xkc1QxQakExFdUi/lo=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    pkg-config
    python3

  ] ++ lib.optionals (withDocs) [
    doxygen
    graphviz
  ];

  buildInputs = [
    glib
    sigrok.libsigrok
    sigrok.libsigrokdecode
  ];


  preConfigure = "./autogen.sh";

  meta = with lib; {
    description = "Command-line frontend for the sigrok signal analysis software suite";
    homepage = "https://sigrok.org/wiki/Sigrok-cli";
    license = licenses.gpl3Plus;
    platforms = platforms.all;
    maintainers = [ maintainers.evils ];
  };
}
