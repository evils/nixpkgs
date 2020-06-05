{ lib
, fetchFromGitLab

# from libsForQt5, in scope because we're using its callPackage
, mkDerivation

, cmake
, extra-cmake-modules
, kdeFrameworks

, qt5
, libsForQt5
, botan2
, sysvtools
, hwdata
, libdrm

, vulkan-tools
, glxinfo
, utillinux
}:

mkDerivation rec {
  pname = "corectrl";
  version = "1.1.0";

  src = fetchFromGitLab {
    owner = "corectrl";
    repo = "corectrl";
    rev = "v${version}";
    sha256 = "049yly8hm3fmw5nsjq0kh6b94vahpl1zh5k5nrj7scl3gk75b4p9";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules ];

  buildInputs = with qt5; with libsForQt5; [
    qtquickcontrols2 qtcharts

    qwt karchive

    kdeFrameworks.kauth

    # non Qt stuff
    botan2
    sysvtools
    hwdata
    libdrm

    # optional
    vulkan-tools
    glxinfo
    utillinux
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DBUILD_TESTING=OFF"
  ];

  meta = with lib; {
    description = "Control with ease your computer hardware using application profiles";
    homepage = "https://gitlab.com/corectrl/corectrl";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = [ maintainers.evils ];
  };
}
