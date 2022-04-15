{ lib, config, pkgs, util, ... }:

with lib;

let cfg = config.cookie.toot;
  inherit (util) mkRequiresScript;
in {
  options.cookie.toot = { enable = mkEnableOption "Enables tooting"; };

  config = mkIf cfg.enable {

    home.packages = [
      (pkgs.makeDesktopItem {
        name = "quick-toot";
        exec = mkRequiresScript ./quick-toot.sh;
        desktopName = "Quick Toot!";
      })
    ];
  };
}
