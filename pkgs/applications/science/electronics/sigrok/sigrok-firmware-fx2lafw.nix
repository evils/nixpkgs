{ lib
, stdenv
, fetchgit

, autoconf
, automake
, sdcc
}:

stdenv.mkDerivation rec {
  pname = "sigrok-firmware-fx2lafw";
  version = "61f1c8fc33ce959f167f6bcb5ba3b0959d60b038";

  src = fetchgit {
    url = "git://sigrok.org/sigrok-firmware-fx2lafw.git";
    rev = version;
    hash = "sha256-mhRFM0DvFXXA56nLbiikd4QMBwoz3c28B4udWHyXBro=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    sdcc
  ];


  preConfigure = "./autogen.sh";

  meta = with lib; {
    description = "Firmware for sigrok for Cypress FX2 chip based hardware";
    homepage = "https://sigrok.org/wiki/Fx2lafw";
    license = licenses.gpl2Plus;
    platforms = platforms.all;
    maintainers = [ maintainers.evils ];
  };
}
