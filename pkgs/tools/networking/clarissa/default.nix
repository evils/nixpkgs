{ lib, stdenv
, fetchFromGitLab
, libpcap, perl, asciidoctor
}:

stdenv.mkDerivation rec {

  pname = "clarissa";
  version = "v1.0";

  src = fetchFromGitLab {
    owner = "evils";
    repo = "clarissa";
    rev = "e962145bf62046dd2df11a47bc676127305a6d80";
    sha256 = "1bpfkvn3i9xyns94pjcgifsdaxm72wc3rk6fk6dv0h96chjfhhqh";
  };

  nativeBuildInputs = [ perl asciidoctor ];
  buildInputs = [ libpcap ];

  doCheck = true;

  makeFlags = [ "DESTDIR=${placeholder "out"}" "PREFIX=" "SYSDINST=false" "GETOUI=false" ];

# currently doesn't work, permission denied on redirecting to tmp file
# also requires an utils based commit
#  OUI = runCommand "clar_OUI" {
#    outputHash = "0000000000000000000000000000000000000000000000000000";
#    outputHashAlgo = "sha256";
#    outputHashMode = "flat";
#    nativeBuildInputs = [ wget ];
#  } ''
#      cd ${src}
#      ${stdenv.shell} utils/OUI_assemble.sh
#      mv clar_OUI.csv > $out/share/clarissa/clar_OUI.csv
#    '';

  meta = with lib; {
    description = "Near-real-time network census daemon";
    longDescription = ''
      Clarissa is a daemon which keeps track of connected MAC addresses on a network.
      It can report these with sub-second resolution and can monitor passively.
    '';
    homepage = "https://gitlab.com/evils/clarissa";
    license = licenses.bsd3;
    platforms = platforms.linux;
    maintainers = [ maintainers.evils ];
  };
}
