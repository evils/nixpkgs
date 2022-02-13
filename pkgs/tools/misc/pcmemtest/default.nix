{ lib, stdenv
, fetchFromGitHub

, iso ? false # makes the output non-reproducible
, dosfstools, mtools
, xorriso
}:

stdenv.mkDerivation rec {
  pname = "pcmemtest";
  version = "1.5";

  src = fetchFromGitHub {
    owner = "martinwhitaker";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-98xy+Cru4k5v4yY6oIGM1WFQeiiZ8AfZR2zlp/MnMdc=";
  };

  postPatch = ''
    substituteInPlace "build32/Makefile" --replace "/sbin/mkdosfs" "${dosfstools}/bin/mkdosfs"
    substituteInPlace "build64/Makefile" --replace "/sbin/mkdosfs" "${dosfstools}/bin/mkdosfs"
  '';

  nativeBuildInputs = lib.optionals (iso) [ dosfstools mtools xorriso ];

  preBuild = if (stdenv.hostPlatform.is32bit) then "cd build32" else "cd build64";

  makeFlags = lib.optionals (iso) [ "iso" ];

  installPhase = ''
    install -Dm0444 -t $out/ memtest.bin
    install -Dm0444 -t $out/ memtest.efi
  '' + lib.optionalString (iso) ''
    install -Dm0444 -t $out/ memtest.iso
  '';

  meta = with lib; {
    homepage = "https://github.com/martinwhitaker/pcmemtest";
    description = "A memory tester for x86 and x86-64 computers";
    license = licenses.gpl2Only;
    platforms = platforms.all;
    maintainers = with maintainers; [ evils ];
  };
}
