import ./make-test-python.nix ({ pkgs, ... } : {
  name = "rasdaemon-aer";
  meta = with pkgs.lib.maintainers; {
    maintainers = [ evils ];
  };

  machine = { pkgs, ... }: {
    imports = [ ../modules/profiles/minimal.nix ];
    hardware.rasdaemon.enable = true;
    boot.kernelPatches = [{
      name = "aer-inject";
      patch = null;
      extraConfig = "PCIEAER_INJECT y";
    }];
    boot.initrd.kernelModules = [ "aer-inject" ];
    environment.systemPackages = [ pkgs.error-inject.aer-inject ];
  };

  testScript =
    ''
      start_all()
      machine.wait_for_unit("multi-user.target")
      # confirm there are no errors to start with
      machine.fail(
          "ras-mc-ctl --errors | tee /dev/stderr | grep -v 'No .* errors.' | sed -r '/^\s*$/d' | grep -q '.*'"
      )
      # inject a correctable error in the ethernet controller? (deterministic?)
      # (fails: Root port not found)
      # works on bare metal, due to being in a VM?
      machine.succeed(
          "aer-inject --id=00:03.0 ${pkgs.error-inject.aer-inject}/examples/mixed-corr-nonfatal >&2"
      )
      # confirm an error was detected
      machine.succeed(
          "ras-mc-ctl --errors | tee /dev/stderr | grep -v 'No .* errors.' | sed -r '/^\s*$/d' | grep -q '.*'"
      )
      machine.shutdown()
    '';
})
