{ lib
, stdenv
, fetchgit
, pkg-config
, libspnav
, qt5
, git-lfs
}:

stdenv.mkDerivation rec {
  pname = "spnavcfg";
  version = "unstable-2023-03-11"; #includes fix for https://github.com/FreeSpacenav/spnavcfg/issues/29

  src = fetchgit {
    fetchLFS = true; # need this when building from git, otherwise we can use fetchFromGitHub
    url = "https://github.com/FreeSpacenav/spnavcfg";
    rev = "4d0fd40f3918810815aa2c733ff30e955c4176c1";
    sha256 = "sha256-mSSXEr2ISaI3XEgvgtPCqL+00YOUPSX/P3zrQ4sM3T0=";
  };

  patches = [
    # Changes the pidfile path from /run/spnavd.pid to $XDG_RUNTIME_DIR/spnavd.pid
    # to allow for a user service
    #./configure-pidfile-path.patch
    # Changes the config file path from /etc/spnavrc to $XDG_CONFIG_HOME/spnavrc or $HOME/.config/spnavrc
    # to allow for a user service
    #./configure-cfgfile-path.patch
  ];

  nativeBuildInputs = [ pkg-config qt5.wrapQtAppsHook git-lfs ];
  buildInputs = [ libspnav qt5.qtbase ];

  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" ];

  meta = with lib; {
    homepage = "https://spacenav.sourceforge.net/";
    description = "Interactive configuration GUI for space navigator input devices";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
    maintainers = with maintainers; [ gebner ];
  };
}
