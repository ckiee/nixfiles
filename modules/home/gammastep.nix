{ lib, config, pkgs, ... }:

let cfg = config.cookie.gammastep;
in with lib; {
  options.cookie.gammastep = {
    enable = mkEnableOption "eye-saving gammastep service";
  };

  config.services.gammastep = mkIf cfg.enable {
    enable = true;
    tray = false; # TODO check if graphical
    provider = "manual";
    latitude = "32.15";
    longitude = "34.8";
  };
}
