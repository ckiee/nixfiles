{ lib, config, pkgs, ... }:

let cfg = config.cookie.screen-locker;

in with lib; {
  options.cookie.screen-locker = {
    enable = mkEnableOption "Enables automatic screen locker activation";
  };

  config = mkIf cfg.enable {
    services.screen-locker = {
      enable = true;
      lockCmd = "slock";
    };
  };
}
