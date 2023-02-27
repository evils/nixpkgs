{ lib
, stdenv
, fetchgit

, autoconf
, automake
}:

stdenv.mkDerivation rec {
  pname = "sigrok-firmware";
  version = "11eed913a9c535b87b5d5b5b92d2622cf34cee8b";

  src = fetchgit {
    url = "git://sigrok.org/sigrok-firmware.git";
    rev = version;
    hash = "sha256-nFBTJ3wvTnLzXwtYOJZvFdDP93mMIUPy6HiGxxruQnQ=";
  };

  nativeBuildInputs = [
    autoconf
    automake
  ];


  preConfigure = "./autogen.sh";

  meta = with lib; {
    description = "Sigrok specific firmware for some of the supported devices";
    homepage = "https://www.sigrok.org/wiki/Firmware";
    license = licenses.unfreeRedistributable;
    platforms = platforms.all;
    maintainers = [ maintainers.evils ];
  };
}
