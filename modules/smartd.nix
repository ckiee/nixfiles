{ config, pkgs, lib, ... }:

let cfg = config.cookie.smartd;
in with lib; {
  options.cookie.smartd = {
    enable = mkEnableOption "Enable SMART disk health monitoring";
  };

  config = mkIf cfg.enable {
    services.smartd = {
      enable = true;
      notifications.x11.enable = config.services.xserver.enable;
    };
  };
}
