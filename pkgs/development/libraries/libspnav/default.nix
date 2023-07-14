{ stdenv, lib, fetchFromGitHub, libX11, fixDarwinDylibNames }:

stdenv.mkDerivation rec {
  pname = "libspnav";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "FreeSpacenav";
    repo = "libspnav";
    rev = "v${version}";
    sha256 = "sha256-qBewSOiwf5iaGKLGRWOQUoHkUADuH8Q1mJCLiWCXmuQ=";
  };

  nativeBuildInputs = lib.optional stdenv.isDarwin fixDarwinDylibNames;
  buildInputs = [ libX11 ];

  patches = [
    # Changes the socket path from /run/spnav.sock to $XDG_RUNTIME_DIR/spnav.sock
    # to allow for a user service
    #./configure-socket-path.patch
  ];

  configureFlags = [ "--disable-debug"];
  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "AR=${stdenv.cc.targetPrefix}ar"
  ];

  preInstall = ''
    mkdir -p $out/{lib,include}
  '';

  meta = with lib; {
    homepage = "https://spacenav.sourceforge.net/";
    description = "Device driver and SDK for 3Dconnexion 3D input devices";
    longDescription = "A free, compatible alternative, to the proprietary 3Dconnexion device driver and SDK, for their 3D input devices (called 'space navigator', 'space pilot', 'space traveller', etc)";
    license = licenses.bsd3;
    platforms = platforms.unix;
    maintainers = with maintainers; [ sohalt ];
  };
}
