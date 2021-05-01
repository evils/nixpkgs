import ./make-test-python.nix ({ pkgs, ... } : {
  name = "rasdaemon";
  meta = with pkgs.lib.maintainers; {
    maintainers = [ evils ];
  };

  machine = { pkgs, ... }: {
    imports = [ ../modules/profiles/minimal.nix ];
    hardware.rasdaemon.testing = true;
  };

  testScript =
    ''
      start_all()
      machine.wait_for_unit("multi-user.target")
      # check if the utilities made it in
      machine.succeed("type edac-tests")
      machine.succeed("type edac-fake-inject")
      machine.succeed("type mce-inject")
      machine.succeed("type aer-inject")
      # check if the required modules have been loaded
      machine.succeed("lsmod | grep -q 'edac_core'")
      machine.succeed("lsmod | grep -q 'i7core_edac'")
      machine.succeed("lsmod | grep -q 'amd64_edac_mod'")
      machine.succeed("lsmod | grep -q 'mce-inject'")
      machine.succeed("lsmod | grep -q 'aer-inject'")
      machine.shutdown()
    '';
})
