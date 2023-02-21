{ lib
, buildPythonApplication
, fetchFromGitHub
, python
, numpy
, tkinter
, libusb
, libsmu
}:

buildPythonApplication rec {
  pname = "alice1";
  version = "1.3.14";

  src = fetchFromGitHub {
    owner = "analogdevicesinc";
    repo = "alice";
    rev = version;
    sha256 = "sha256-w1Je9IGvxZgcqqM4xFuiwWfqfBADYJyc6olqorKlkAA=";
  };

  propagatedBuildInputs = with python.pkgs; [
    python
    numpy
    tkinter
    libusb
    libsmu
    pysmu
    pysmu-bindings
  ];

  format = "other";

  installPhase = ''
    mkdir -p $out/bin
    cp $src/*.pyw $out/bin/
    cp $src/*.ini $out/bin/
    chmod +x $out/bin/*.pyw
  '';

  catchConflicts = false;

  meta = with lib; {
    description = "Analog Devices GUI for the ADALM1000";
    longDescription = "Active Learning Interface for Circuits and Electronics";
    homepage = "https://wiki.analog.com/university/tools/m1k/alice/desk-top-users-guide";
    license = licenses.unfreeRedistributable;
    platforms = platforms.all;
    maintainers = [ maintainers.evils ];
  };
}
