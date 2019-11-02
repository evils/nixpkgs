{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.xserver.windowManager.matwm2;

in {
  options.services.xserver.windowManager.matwm2 = {

    enable = mkEnableOption "matwm2";

    config = mkOption {
      default = null;
      type = types.lines;
      description = "Configuration file, see <citerefentry><refentrytitle>matwm2</refentrytitle><manvolnum>1</manvolnum></citerefentry> for more options";
      example = literalExample ''
        background               blue
        key                      control mod1 space      exec dmenu_run
      '';
    };

    extraPackages = mkOption {
      type = with types; listOf package;
      default = [ ];
      example = literalExample "with pkgs; [ dmenu ]";
      description = "Extra packages to be installed system wide.";
    };
  };


  config = mkIf cfg.enable {
    services.xserver.windowManager.session = [{
      name = "matwm2";
      start = ''
	${pkgs.matwm2}/bin/matwm2 &
	waitPID=$!
      '';
    }];
    environment.systemPackages = [ pkgs.matwm2 ] ++ cfg.extraPackages;
    environment.etc."matwmrc".text = cfg.config;
  };
}
