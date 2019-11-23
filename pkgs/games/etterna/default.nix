{ lib, stdenv, fetchFromGitHub, cmake, ninja
, openssl, libX11, libXrandr, curl, libGLU, libXext
, libogg, luaPackages, doxygen, graphviz, pkgconfig
, libpulseaudio, alsaLib, jack2
}:

with lib;
stdenv.mkDerivation rec {
  pname = "etterna";
  version = "develop";

  src = fetchFromGitHub {
    owner = "etternagame";
    repo = "${pname}";
    rev = "be0e318ce7cf5b5c7ec9009faa97d893d005bd5a";
    sha256 = "16xdvhmnsxllbj1vxsv81qqi1rc4gbyb74h6mfqd34q7gafqiwp8";
  };

  # bad devs...
  NIX_CFLAGS_COMPILE = ["-Wno-error=format-security"];

  # make the relevant warnings stand out better
  cmakeFlags = [ "-Wno-dev" ];

  nativeBuildInputs = [
    cmake ninja luaPackages.ldoc doxygen
    graphviz pkgconfig
  ];

  buildInputs = [
    openssl libX11 libXrandr curl libGLU libXext
    libogg libpulseaudio alsaLib jack2
  ];

}
