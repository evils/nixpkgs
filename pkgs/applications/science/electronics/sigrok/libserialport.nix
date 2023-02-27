{ lib
, stdenv
, fetchgit

, autoconf
, automake
, libtool
}:

stdenv.mkDerivation rec {
  pname = "libserialport";
  version = "6f9b03e597ea7200eb616a4e410add3dd1690cb1";

  src = fetchgit {
    url = "git://sigrok.org/libserialport.git";
    rev = version;
    hash = "sha256-o1BTBCwyouFCZx0GXXrJs33Y2sp5Iq45pJhLMxHQceA=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
  ];

  preConfigure = "./autogen.sh";

  doCheck = true;

  meta = with lib; {
    description = "Cross-platform shared library for serial port access";
    homepage = "https://www.sigrok.org/wiki/Libserialport";
    license = licenses.gpl3Plus;
    platforms = platforms.all;
    maintainers = [ maintainers.evils ];
  };
}
