{ lib
, buildPythonPackage
, fetchFromGitHub
, pytestCheckHook
, pythonOlder
, rustPlatform
, libiconv
, dirty-equals
, pytest-benchmark
}:

buildPythonPackage rec {
  pname = "rtoml";
  version = "0.9";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "samuelcolvin";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-Vk/0SGtYhxZFIr/WuXadypZp07kPyzZp7N/1sFSI5dk=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-fsAClhZomJngMfV78XZl9hy+EFfpSBanjmgqmoc5ySQ=";
  };

  nativeBuildInputs = with rustPlatform; [
    maturinBuildHook
    cargoSetupHook
  ];

  buildInputs = [
    libiconv
  ];

  pythonImportsCheck = [
    "rtoml"
  ];

  nativeCheckInputs = [
    pytestCheckHook
    dirty-equals
    pytest-benchmark
  ];

  preCheck = ''
    cd tests
    substituteInPlace test_benchmarks.py --replace tests/data.toml data.toml
  '';

  meta = with lib; {
    description = "Rust based TOML library for Python";
    homepage = "https://github.com/samuelcolvin/rtoml";
    license = licenses.mit;
    maintainers = with maintainers; [ evils ];
  };
}
