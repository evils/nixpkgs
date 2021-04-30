import ./make-test-python.nix ({ pkgs, ... } : {
  name = "rasdaemon";
  meta = with pkgs.lib.maintainers; {
    maintainers = [ evils ];
  };

  machine = { pkgs, ... }: {
    imports = [ ../modules/profiles/minimal.nix ];
    hardware.rasdaemon.enable = true;
  };

  testScript =
    ''
      start_all()
      machine.wait_for_unit("multi-user.target")
      # confirm rasdaemon is running and has a valid database
      # some disk errors detected in qemu for some reason ¯\_(ツ)_/¯
      machine.succeed(
          "ras-mc-ctl --errors | tee /dev/stderr | grep -iq 'No PCIe AER errors.'"
      )
      machine.succeed(
          "${pkgs.pciutils}/bin/lspci >&2"
      )
      # TODO: figure this out...
      # https://github.com/qemu/qemu/blob/master/hmp-commands.hx#L1241
      machine.send_monitor_command("pcie_aer_inject_error 00:00.0")
      machine.fail("ras-mc-ctl --errors | tee /dev/stderr | grep -iq 'No PCIe AER errors.'")
      machine.shutdown()
    '';
})
