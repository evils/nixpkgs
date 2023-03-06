{ lib, stdenv
, fetchgit
, cmake
, gd
, libusb1
, gettext
, git
, pkg-config
}:

stdenv.mkDerivation rec {
  pname = "ptouch-print";
  version = "v1.5-9-g6b82cd6";

  src = fetchgit {
    url = "https://git.familie-radermacher.ch/linux/ptouch-print.git";
    rev = "6b82cd6166745505849004cd3ef4a21cfb2336e6";
    hash = "sha256-stg8lm06wcBCE6fL0ehwepcHuFoT0lFHLKPL3QNT6lg=";
  };

  preConfigure = ''
    substituteInPlace CMakeLists.txt --replace "/usr" "${placeholder "out"}"
  '';

  # doesn't work, hence the above SubstituteInPlace
  /*
  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
  ];
  */

  nativeBuildInputs = [
    cmake
    gettext
    git
    pkg-config
  ];

  buildInputs = [
    gd
    libusb1
  ];

  meta = with lib; {
    description = "Command line tool to print labels on Brother P-Touch printers on Linux";
    license = licenses.gpl3Only;
    homepage = "https://dominic.familie-radermacher.ch/projekte/ptouch-print/";
    maintainers = with maintainers; [ shamilton evils ];
    platforms = platforms.linux;
  };
}
