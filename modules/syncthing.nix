{ lib, config, pkgs, ... }:

let cfg = config.cookie.syncthing;

in with lib; {
  options.cookie.syncthing = {
    enable = mkEnableOption "Enables Syncthing file syncing";
  };

  config.services.syncthing = mkIf cfg.enable {
    enable = true;
    user = "ron";
    dataDir = "/home/ron";
  };
}
