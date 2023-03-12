{ lib
, stdenv
, fetchFromGitHub

, autoconf
, automake
, perl

, cups
, libpng
}:

stdenv.mkDerivation rec {
  pname = "printer-driver-ptouch";
  version = "1.6";

  src = fetchFromGitHub {
    owner = "philpem";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-s1l25PsnUwvZljLEZbuRpwC8n9Vzu1b+mhyTbJmdkLA=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    perl
    perl.pkgs.XMLLibXML
  ];

  buildInputs = [
    cups
    libpng
  ];

  preConfigure = ''
    patchShebangs .
    ./autogen.sh
  '';

  doCheck = true;

  meta = with lib; {
    description = "Brother P-Touch PT-series and QL-series printer driver based on CUPS";
    homepage = "https://github.com/philpem/printer-driver-ptouch";
    license = licenses.gpl2Plus;
    platforms = platforms.all;
    maintainers = [ maintainers.evils ];
  };
}
