{ lib
, buildPythonPackage
, pythonOlder
, isPy27
, isPyPy
, cython
, distlib
, fetchPypi
, filelock
, flaky
, hatch-vcs
, hatchling
, importlib-metadata
, platformdirs
, pytest-freezegun
, pytest-mock
, pytest-timeout
, pytestCheckHook
, time-machine
}:

buildPythonPackage rec {
  pname = "virtualenv";
  version = "20.25.3";
  format = "pyproject";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-e7VUu9/qrMM0n6YU6lv/asMA/HwzXp+s86O8/HA/Rb4=";
  };

  nativeBuildInputs = [
    hatch-vcs
    hatchling
  ];

  propagatedBuildInputs = [
    distlib
    filelock
    platformdirs
  ] ++ lib.optionals (pythonOlder "3.8") [
    importlib-metadata
  ];

  nativeCheckInputs = [
    cython
    flaky
    pytest-freezegun
    pytest-mock
    pytest-timeout
    pytestCheckHook
  ] ++ lib.optionals (!isPyPy) [
    time-machine
  ];

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  disabledTestPaths = [
    # Ignore tests which require network access
    "tests/unit/create/test_creator.py"
    "tests/unit/seed/embed/test_bootstrap_link_via_app_data.py"
  ];

  disabledTests = [
    # Network access
    "test_create_no_seed"
    "test_seed_link_via_app_data"
    # Permission Error
    "test_bad_exe_py_info_no_raise"
  ] ++ lib.optionals (pythonOlder "3.11") [
    "test_help"
  ] ++ lib.optionals (isPyPy) [
    # encoding problems
    "test_bash"
    # permission error
    "test_can_build_c_extensions"
    # fails to detect pypy version
    "test_discover_ok"
  ];

  pythonImportsCheck = [
    "virtualenv"
  ];

  meta = with lib; {
    description = "A tool to create isolated Python environments";
    mainProgram = "virtualenv";
    homepage = "http://www.virtualenv.org";
    changelog = "https://github.com/pypa/virtualenv/blob/${version}/docs/changelog.rst";
    license = licenses.mit;
    maintainers = with maintainers; [ goibhniu ];
  };
}
