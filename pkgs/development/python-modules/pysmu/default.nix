{ lib
, libsmu
, buildPythonPackage
, build
, wheel
, setuptools
, cython
, six
, test-the-bindings ? false
}:

buildPythonPackage rec {
  pname = "pysmu";
  version = libsmu.version;

  src = libsmu.src;

  buildInputs = [ libsmu ] ++ libsmu.buildInputs;

  nativeBuildInputs = libsmu.nativeBuildInputs ++ [
    build
    wheel
    setuptools
    cython
    six
  ];

  cmakeFlags = libsmu.cmakeFlags ++ [ "-DBUILD_PYTHON=ON" ];

  preBuild = if (test-the-bindings) then ''
    cd ../bindings/python
  '' else "";

  format = "pyproject";

  meta = with lib; {
    description = "Python bindings for libsmu, the software abstraction for the ADALM1000 USB SMU";
    homepage = "https://analogdevicesinc.github.io/libsmu/";
    license = licenses.bsd3;
    maintainers = with maintainers; [ evils ];
  };
}
