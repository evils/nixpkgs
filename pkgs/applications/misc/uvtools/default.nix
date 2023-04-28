{ lib
, buildDotnetModule
, fetchFromGitHub
, dotnetCorePackages
, libjpeg
, libjpeg_turbo
, libpng
, libgeotiff
, libdc1394
, openexr
, libgdiplus
, tbb
, ffmpeg
}:

buildDotnetModule rec {
  pname = "UVtools";
  version = "3.13.1";

  src = fetchFromGitHub {
    owner = "sn4k3";
    repo = "UVtools";
    rev = "v${version}";
    sha256 = "sha256-lVIdIIjg9JQk/woie+ROieAlI9ghfK2jFdDSzea3cHU=";
  };

  projectFile = "UVtools.sln";
  nugetDeps = ./deps.nix;
  executables = [ "UVtools" ];

  nativeBuildInputs = [
  ];

  buildInputs = [
    libjpeg
    libjpeg_turbo
    libpng
    libgeotiff
    libdc1394
    openexr
    libgdiplus
    tbb
    ffmpeg
  ];

  runtimeDeps = [
  ];

  meta = with lib; {
    description = "MSLA/DLP resin 3D printing file analysis, calibration, repair, conversion and manipulation";
    homepage = "https://github.com/sn4k3/UVtools";
    mainProgram = "uvtools";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ evils ];
    platforms = platforms.all;
  };
}
