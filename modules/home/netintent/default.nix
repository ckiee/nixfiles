{ lib, config, pkgs, util, ... }:

with lib;

let cfg = config.cookie.netintent;
  inherit (util) mkRequiresScript;
in {
  options.cookie.netintent = { enable = mkEnableOption "Enables netintenting"; };

  config = mkIf cfg.enable {

    home.packages = [
      (pkgs.makeDesktopItem {
        name = "quick-netintent";
        exec = mkRequiresScript ./quick-netintent.sh;
        desktopName = "Quick Netintent!";
      })
    ];
  };
}
