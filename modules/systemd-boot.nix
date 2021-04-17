{ config, lib, pkgs, ... }:

let cfg = config.cookie.systemd-boot;
in with lib; {
  options.cookie.systemd-boot = {
    enable = mkEnableOption "Enables the systemd-boot bootloader";
  };

  config = mkIf cfg.enable {
    boot.loader.systemd-boot = {
      enable = true;
      editor = false;
      configurationLimit = 120;
    };
  };
}
