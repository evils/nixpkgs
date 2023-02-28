{ lib
, stdenv
, fetchFromGitHub
, python3

, sigrok
}:

python3.pkgs.buildPythonApplication rec {
  pname = "pysigrok-libsigrokdecode";
  version = "259dbb9781b8efe58a679d573b01f5c6c1e5fa2f";

  src = fetchFromGitHub {
    owner = "pysigrok";
    repo = "libsigrokdecode";
    rev = version;
    hash = "sha256-r04WJHGd7skuP03k/cYf046Zg4eq54jWBEkuzkV8q0k=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    sigrok.pysigrok
    flit-core
  ];

  format = "pyproject";

  meta = with lib; {
    description = "Python reimplementation of sigrok core";
    homepage = "https://github.com/pysigrok/pysigrok";
    license = licenses.gpl3Plus;
    platforms = platforms.all;
  };
}
