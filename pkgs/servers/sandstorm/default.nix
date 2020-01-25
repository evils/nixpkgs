{ stdenv, lib, fetchgit
, python3, go, cmake, zlib
, which
, libpcap, strace, curl
, discount, git, meteor
, xz, zip, unzip
}:

stdenv.mkDerivation rec {
  pname = "sandstorm";
  version = "0.257";

  src = fetchgit {
    url = "https://github.com/sandstorm-io/sandstorm.git";
    rev = "v${version}";
    sha256 = "1cikpihf64q6yz8z7ff0lbz98c4z7g6ygr5fbi0f0jam2qv0ii6x";
    fetchSubmodules = true;
    leaveDotGit = true;
  };

  nativeBuildInputs = [ git which ];

  buildInputs = [
    libpcap xz zip unzip
    curl python3 zlib go
    meteor discount ];

  meta = with stdenv.lib; {
    description = "A self-hostable web productivity suite";
    longDescription = ''
      Sandstorm is an open source project built by a community of volunteers with the goal of making it really easy to run open source web applications.
    '';
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = [ maintainers.evils ];
  };

}
