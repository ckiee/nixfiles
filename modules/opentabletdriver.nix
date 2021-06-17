{ lib, config, pkgs, ... }:

let cfg = config.cookie.opentabletdriver;
in with lib; {
  options.cookie.opentabletdriver = {
    enable = mkEnableOption "Enables and configures OpenTabletDriver";
  };

  config = mkIf cfg.enable {
    hardware.opentabletdriver.enable = true;

    home-manager.users.ckie = { ... }: {
      xdg.configFile."OpenTabletDriver/settings.json".source = ../ext/otd.json;
    };
  };
}
