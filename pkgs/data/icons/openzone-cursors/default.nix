{ stdenv
, fetchFromGitHub
, icon-slicer
}:

stdenv.mkDerivation rec {
  pname = "openzone-cursors";
  version = "1.2.8";

  src = fetchFromGitHub {
    owner = "ducakar";
    repo = "openzone-cursors";
    rev = "v${version}";
    sha256 = "0r3f65qqzjkp5kh1bzlrrppv6d9akg22242mwamalw7c8sigqfa5";
  };

  nativeBuildInputs = [ icon-slicer ];

  meta = with stdenv.lib; {
    description = "Mouse cursor theme for X11 and Wayland";
    homepage = "https://www.opendesktop.org/p/999999/";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [ maintainers.evils ];
  };
}
