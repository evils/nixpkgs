import ./make-test-python.nix ({ pkgs, ... } : {
  name = "rasdaemon-mce";
  meta = with pkgs.lib.maintainers; {
    maintainers = [ evils ];
  };

  machine = { pkgs, ... }: {
    imports = [ ../modules/profiles/minimal.nix ];
    hardware.rasdaemon.enable = true;
    boot.kernelPatches = [{
      name = "mce-inject";
      patch = null;
      extraConfig = "X86_MCE_INJECT y";
    }];
    # not sure if the edac modules are needed...
    boot.initrd.kernelModules = [ "edac_core" "amd64_edac_mod" "mce-inject" ];
    environment.systemPackages = [ pkgs.error-inject.mce-inject ];
  };

  testScript =
    ''
      start_all()
      machine.wait_for_unit("multi-user.target")
      # confirm there are no errors to start with
      machine.fail(
          "ras-mc-ctl --errors | tee /dev/stderr | grep -v 'No .* errors.' | sed -r '/^\s*$/d' | grep -q '.*'"
      )
      # inject a correctable error
      machine.succeed(
          "mce-inject ${pkgs.error-inject.mce-inject}/test/corrected >&2"
      )
      # confirm an error was detected
      machine.succeed(
          "ras-mc-ctl --errors | tee /dev/stderr | grep -v 'No .* errors.' | sed -r '/^\s*$/d' | grep -q '.*'"
      )
      machine.shutdown()
    '';
})
