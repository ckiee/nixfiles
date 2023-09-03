{ lib, config, pkgs, ... }:

let cfg = config.cookie.picom;

in with lib; {
  options.cookie.picom = {
    enable = mkEnableOption "Picom compositor";
  };

  config = mkIf cfg.enable {
    services.picom = {
      enable = true;
      # blur = true;
      # experimentalBackends = true;
      # refreshRate = 144;
      # vSync = false;
    };
  };
}
