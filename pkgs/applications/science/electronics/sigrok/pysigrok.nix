{ lib
, stdenv
, fetchFromGitHub
, python3
}:

python3.pkgs.buildPythonApplication rec {
  pname = "pysigrok";
  version = "aed0a9814d19551a54c0e929bf1143f78187bd98";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = version;
    hash = "sha256-YtV6cPHpkeKNco4ce4/ZRZJmm4NUpJQ26gcJ0Yun+8k=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    # pysigrok-hardware-raspberrypi-pico
    # pysigrok-libsigrokdecode
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
