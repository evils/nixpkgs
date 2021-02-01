import ./make-test-python.nix ({ pkgs, ... } : {
  name = "rasdaemon-edac";
  meta = with pkgs.lib.maintainers; {
    maintainers = [ evils ];
  };

  machine = { pkgs, ... }: {
    imports = [ ../modules/profiles/minimal.nix ];
    hardware.rasdaemon.enable = true;
    boot.kernelPatches = [{
      name = "edac-inject";
      patch = null;
      extraConfig = "EDAC_DEBUG y";
    }];
    boot.initrd.kernelModules = [ "edac_core" "amd64_edac_mod" ];
    environment.systemPackages = [ pkgs.error-inject.edac-inject ];
  };

  testScript =
    ''
      start_all()
      machine.wait_for_unit("multi-user.target")
      # confirm there are no errors to start with
      machine.fail(
          "ras-mc-ctl --errors | tee /dev/stderr | grep -v 'No .* errors.' | sed -r '/^\s*$/d' | grep -q '.*'"
      )
      # run tests?
      # (hangs, no ECC in VM?)
      machine.succeed("timeout 10 edac-tests >&2")
      # confirm an error was detected
      machine.succeed(
          "ras-mc-ctl --errors | tee /dev/stderr | grep -v 'No .* errors.' | sed -r '/^\s*$/d' | grep -q '.*'"
      )
      machine.shutdown()
    '';
})
