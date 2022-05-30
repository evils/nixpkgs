{ lib
, stdenv
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {

  pname = "scrutiny";
  version = "0.4.8";

  src = fetchFromGitHub {
    owner = "AnalogJ";
    repo = "scrutiny";
    rev = "v${version}";
    sha256 = "sha256-+gQ2mjb1MCuDNbmSZrabYTa0V4rJYN3MNY7nQ30LLHg=";
  };

  vendorSha256 = "sha256-U5Mbfy+YW4JRy8g5Fae8zglbG7YIt3XW4CCVW2g0vx4=";

  doCheck = false; # some of the tests try to contact influxdb on localhost:8086

  meta = with lib; {
    description = "Web UI for Hard Drive S.M.A.R.T Monitoring, Historical Trends & Real World Failure Thresholds";
    homepage = "https://github.com/AnalogJ/scrutiny";
    license = licenses.mit;
    maintainers = with maintainers; [ evils ];
  };
}
