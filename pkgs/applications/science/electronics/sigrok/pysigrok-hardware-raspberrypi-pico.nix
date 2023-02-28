{ lib
, stdenv
, fetchFromGitHub
, python3

, sigrok
}:

python3.pkgs.buildPythonApplication rec {
  pname = "pysigrok-hardware-rapsberrypi-pico";
  version = "9f1c6b84b7089783454962f4eb185ee54ca93b1d";

  src = fetchFromGitHub {
    owner = "pysigrok";
    repo = "hardware-raspberrypi-pico";
    rev = version;
    hash = "sha256-5Y+w7wTFUKi6pK5Q/cpw9qhxQBclOUDSPOieGDDWMzI=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    sigrok.pysigrok
    flit-core
    click
    importlib-metadata
    pyserial
  ];

  format = "pyproject";

  meta = with lib; {
    description = "Python reimplementation of sigrok core";
    homepage = "https://github.com/pysigrok/pysigrok";
    license = licenses.gpl3Plus;
    platforms = platforms.all;
  };
}
