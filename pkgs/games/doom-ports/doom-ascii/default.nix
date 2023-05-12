{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "doom-ascii";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "wojciech-graj";
    repo = "doom-ascii";
    rev = "v${version}";
    hash = "sha256-0Z/BLPQ4PXUMira8tcBdGeY2Dqhzcl8xZPepPz+9Zgg=";
  };

  sourceRoot = "source/src";

  makeFlags = [ "BINDIR=$(out)/bin" ];

  dontInstall = true;

  meta = with lib; {
    description = "DooM in the terminal";
    homepage = "https://github.com/wojciech-graj/doom-ascii";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ evils ];
  };
}
