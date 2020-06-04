{ stdenv, lib
, fetchFromGitHub
, makeWrapper
, installShellFiles

, byobu, tmux

, atop, bmon
, cmatrix, htop
, ccze, jp2a, tree
, moreutils, coreutils

/* suggested but no scripts included
, nmon, procps
, tiptop
*/

, big ? false # large closure size
, openssh, speedometer
, mplayer, hexdump, utillinux
# , glances, slurm # suggested, no scripts

/* suggested, require root, no scripts
, root ? false
, iotop
, dnstop, powertop
*/
}:

stdenv.mkDerivation rec {
  pname = "hollywood";
  version = "1.21";

  src = fetchFromGitHub {
    owner = "dustinkirkland";
    repo = "hollywood";
    rev = "c3ccb48900c09e57b67cb8f1657ebe48b25ec8b8";
    sha256 = "1v3zb5cakpjdq3w0wc5ns4g8kwbfy4yv3rrhb4ay7i8s6c9ks6ry";
  };

  nativeBuildInputs = [ makeWrapper installShellFiles ];

  buildInputs = [ byobu tmux
    atop bmon cmatrix htop ccze jp2a tree moreutils coreutils ];

  outputs = [ "out" "man" ];

  installPhase = ''
    install -Dm 0755 $src/bin/hollywood $out/bin/hollywood

    substituteInPlace $out/bin/hollywood --replace \
      "byobu" "byobu-tmux"

    substituteInPlace $out/bin/hollywood --replace \
      "\$(dirname \$0)/.." "${placeholder "out"}"

    wrapProgram $out/bin/hollywood \
      --prefix PATH : ${lib.makeBinPath buildInputs}

    mkdir -p $out/share/
    cp -r $src/share/hollywood $out/share/.

    installManPage $src/share/man/man1/hollywood.1

    # relatively small closure size packages
    scripts=( "apg" "atop" "bmon" "cmatrix" "errno" "htop" "logs" "map" "stat" "tree" )

    # bigger closure size packages
    if [ "$big" == "true" ]; then
      scripts+=( "hexdump" "mplayer" "speedometer" "sshart" )
    fi

    for s in "''${scripts[@]}"
    do
      install -Dm 0755 $src/lib/hollywood/$s $out/lib/hollywood/$s
    done

    if [ "$big" == "true" ]; then
      substituteInPlace $out/lib/hollywood/speedometer --replace "speedometer" "speedometer.py"
    fi
  '';

  meta = with lib; {
    description = "Fill your console with Hollywood melodrama technobabble";
    homepage = "https://hollywood.computer";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = [ maintainers.evils ];
  };
}
