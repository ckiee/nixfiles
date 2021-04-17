{ lib, config, pkgs, ... }:

let cfg = config.cookie.redshift;
in with lib; {
  options.cookie.redshift = {
    enable = mkEnableOption "Enables the eye-saving redshift service";
  };

  config.services.redshift = mkIf cfg.enable {
    enable = true;
    tray = false; # TODO check if graphical
    provider = "manual";
    latitude = "32.15";
    longitude = "34.8";
  };
}
