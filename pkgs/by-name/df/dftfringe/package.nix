{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  qt6,
  opencv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dftfringe";
  version = "7.3.3";

  src = fetchFromGitHub {
    owner = "githubdoe";
    repo = "DFTFringe";
    rev = "v${finalAttrs.version}";
    hash = "sha256-vMJ6tTgN94u0YyiyFH03VkZwxZg1L5i/kV4xNjiqK0Q=";
  };

  nativeBuildInputs = with qt6; [
    pkg-config
    qmake
    qttools
    wrapQtAppsHook
    opencv
  ];

  buildInputs = [
    qt6.qtbase
  ];

  configurePhase = ''
    runHook preConfigure
    qmake -makefile -Wall
    runHook postConfigure
  '';

  meta = {
    description = "DFTFringe Telescope Mirror interferometry analysis Program";
    homepage = "https://github.com/githubdoe/DFTFringe.git";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "dftfringe";
    platforms = lib.platforms.all;
  };
})
