{ lib, config, pkgs, ... }:

let cfg = config.cookie.nautilus;
in with lib; {
  options.cookie.nautilus = {
    enable = mkEnableOption "Enables forcing of some Nautilus preferences";
  };

  config = mkIf cfg.enable {
    programs.dconf.enable = true;
    dconf.settings."org/gnome/nautilus/preferences" = {
      default-sort-in-reverse-order = true;
      default-sort-order = "mtime";
    };
    home.packages = with pkgs; [
      gnome3.nautilus
      gnome3.gvfs # nautilus likes this!
    ];
  };
}
