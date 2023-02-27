{ callPackage
, libsForQt5
}:

{
  libsigrok = callPackage ./libsigrok.nix { };
  libsigrokdecode = callPackage ./libsigrokdecode.nix { };
  libserialport = callPackage ./libserialport.nix { };
  sigrok-cli = callPackage ./sigrok-cli.nix { };
  pulseview = libsForQt5.callPackage ./pulseview.nix { };
  smuview = libsForQt5.callPackage ./smuview.nix { };
  sigrok-firmware = callPackage ./sigrok-firmware.nix { };
  sigrok-firmware-fx2lafw = callPackage ./sigrok-firmware-fx2lafw.nix { };
  pysigrok = callPackage ./pysigrok.nix { };
}
