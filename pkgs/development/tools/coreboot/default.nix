{ lib, stdenv, fetchgit
, flex, ncurses
, libmpc, mpfr
, gnat, isl
, zlib, gmp
, m4, bison
, curl, git
}:

stdenv.mkDerivation rec {

  pname = "coreboot-build";
  version = "4.11";

  src = fetchgit {
    url = "https://review.coreboot.org/coreboot.git";
    rev = version;
    sha256 = "1w8nar8szz2khx5s7vljg2whwllf3nypszx70f6klzwynr7q348c";
  };

  nativeBuildInputs = [
    curl git gnat isl
    m4 bison flex ncurses
    zlib gmp libmpc mpfr
  ];

  config = builtins.readFile ./config;

  preConfigurePhase = ''
    echo $config > .config
  '';

  preBuildPhase = ''
    make crossgcc-i386
  '';

  meta = with stdenv.lib; {
    description = "Fast, secure and flexible OpenSource firmware";
    longDescription = "coreboot is an extended firmware platform that delivers a lightning fast and secure boot experience on modern computers and embedded systems. As an Open Source project it provides auditability and maximum control over technology.";
    homepage = "https://www.coreboot.org";
    license = licenses.gpl2;
    platform = platforms.linux;
    maintainers = [ maintainers.evils ];
  };
}
