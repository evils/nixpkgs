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

  pysigrok-hardware-raspberrypi-pico = callPackage ./pysigrok-hardware-raspberrypi-pico.nix { };
  pysigrok-libsigrokdecode = callPackage ./pysigrok-libsigrokdecode.nix { };
  pysigrok = callPackage ./pysigrok.nix { };
}
