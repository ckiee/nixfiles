{ lib, config, pkgs, ... }:

let cfg = config.cookie.steam;

in with lib; {
  options.cookie.steam = { enable = mkEnableOption "Enables steam"; };

  config = mkIf cfg.enable {
    programs.steam.enable = true;

    programs.gamemode = {
      enable = true;
      enableRenice = true;
    };
  };
}
