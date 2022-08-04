{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, python3
, perl
, neon
, libusb
, openssl
, udev
, avahi
, freeipmi
, libtool
, makeWrapper
, autoconf
, automake
, libmodbus
, i2c-tools
, net-snmp
, gd

, cppcheck
, cppunit

, asciidoc
, libxslt
, libxml2
, sourceHighlight
}:

stdenv.mkDerivation rec {
  pname = "nut";
  version = "2.8.0";

  src = fetchFromGitHub {
    owner = "networkupstools";
    repo = "nut";
    rev = "v${version}";
    hash = "sha256-i2lE6LJ1I/3Jb1mK63/G2MYyHXooAfEXY65vx6dmAj4=";
  };

  buildInputs = [ neon libusb openssl udev avahi freeipmi libmodbus gd i2c-tools net-snmp ];

  nativeBuildInputs = [
    python3 perl
    autoconf automake libtool pkg-config makeWrapper
    asciidoc libxslt libxml2 sourceHighlight
    cppunit
  ];

  checkInputs = [ cppcheck ];
  doCheck = true; # i'm not sure this does anything

  preConfigure = ''
    patchShebangs autogen.sh
    patchShebangs tools/nut-usbinfo.pl
    ./autogen.sh
  '';

  configureFlags =
    [
      "--with-all"
      "--with-ssl"
      "--without-powerman" # Until we have it ...
      "--without-snmp" # nut-snmp.h is not generated due to not finding python to do so
      "--with-systemdsystemunitdir=$(out)/etc/systemd/system"
      "--with-systemdshutdowndir=$(out)/lib/systemd"
      "--with-systemdtmpfilesdir=$(out)/lib/tmpfiles.d"
      "--with-udev-dir=$(out)/etc/udev"
    ];

  postInstall = ''
    wrapProgram $out/bin/nut-scanner --prefix LD_LIBRARY_PATH : \
      "$out/lib:${neon}/lib:${libusb.out}/lib:${avahi}/lib:${freeipmi}/lib"
  '';

  outputs = [ "out" "man" ];

  meta = with lib; {
    description = "Network UPS Tools";
    longDescription = ''
      Network UPS Tools is a collection of programs which provide a common
      interface for monitoring and administering UPS, PDU and SCD hardware.
      It uses a layered approach to connect all of the parts.
    '';
    homepage = "https://networkupstools.org/";
    platforms = platforms.linux;
    maintainers = [ maintainers.pierron ];
    license = with licenses; [ gpl1Plus gpl2Plus gpl3Plus ];
    priority = 10;
  };
}
