{ config, lib, pkgs, ... }:

let cfg = config.cookie.qt5;
in with lib; {
  options.cookie.qt5 = {
    enable = mkEnableOption "Enables Qt5 theming";
  };

  config = mkIf cfg.enable {
    qt5 = {
      enable = true;
      style = "adwaita-dark";
      platformTheme = "gnome";
    };
  };
}
