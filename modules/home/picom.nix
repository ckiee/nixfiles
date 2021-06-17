{ lib, config, pkgs, ... }:

let cfg = config.cookie.picom;

in with lib; {
  options.cookie.picom = {
    enable = mkEnableOption "Enables the Picom compositor";
  };

  config = mkIf cfg.enable {
    services.picom = {
      enable = true;
      blur = true;
      experimentalBackends = true;
    };
  };
}
