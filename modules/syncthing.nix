{ lib, config, pkgs, ... }:

let cfg = config.cookie.syncthing;

in with lib; {
  options.cookie.syncthing = {
    enable = mkEnableOption "Enables Syncthing file syncing";
  };

  config.services.syncthing = mkIf cfg.enable rec {
    enable = true;
    user = "ckie";
    dataDir = "/home/${user}";
  };
}
