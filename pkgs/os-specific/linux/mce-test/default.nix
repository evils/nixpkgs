{ lib, stdenv, fetchgit, runCommand
, bison, flex
, rasdaemon, error-inject, linuxPackages
}:

stdenv.mkDerivation rec {

  pname = "mce-test";
  # v1.0 doesn't compile, this is the latest commit (at writing)
  version = "7643baf";

  src = fetchgit {
    url = "git://git.kernel.org/pub/scm/utils/cpu/mce/mce-test.git";
    rev = version;
    sha256 = "1sxbm10x35668vhkk70fr1y03zg4yj3qy54l1yzl1jkhkxag4nbg";
  };

  buildInputs = with error-inject; with linuxPackages; [
    rasdaemon mce-inject vm-tools
  ];

  meta = with lib; {
    description = "MCE test suite for linux RAS features, with APEI error injection";
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = [ maintainers.evils ];
  };
}
