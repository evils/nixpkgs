{ stdenv
, fetchurl
, pkg-config
, gtk2, popt
, xcursorgen
, automake
}:

stdenv.mkDerivation rec {
  pname = "icon-slicer";
  version = "0.3";

  src = fetchurl {
    url = "https://freedesktop.org/software/${pname}/releases/${pname}-${version}.tar.gz";
    sha256 = "0kdnc08k2rs8llfg7xgvnrsk60x59pv5fqz6kn2ifnn2s1nj3w05";
  };

  nativeBuildInputs = [ pkg-config xcursorgen ];

  buildInputs = [ gtk2 popt xcursorgen ];


# this block did not help...
/*
  makeFlags = [ "prefix=${placeholder "out"}" ];

  preBuild = ''
    substituteInPlace src/main.c --replace "sh -c 'xcursorgen" "${stdenv.shell} -c 'xcursorgen"
    substituteInPlace src/main.c --replace "/usr" "${placeholder "out"}"
  '';
*/

  meta = with stdenv.lib; {
    decription = "A utility for genarating icon themes and libXcursor cursor themes";
    homepage = "https://www.freedesktop.org/wiki/Software/icon-slicer/";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [ maintainers.evils ];
  };
}
