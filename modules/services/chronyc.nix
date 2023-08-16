{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.chronyc;

in with lib; {
  options.cookie.services.chronyc = {
    enable = mkEnableOption
      "Enables the chrony client timesync daemon, replacing sd-timesyncd";
  };

  config = mkIf cfg.enable {
    services = {
      timesyncd.enable = false;
      chrony.enable = true;
    };
  };
}
