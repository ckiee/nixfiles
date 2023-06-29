{ config, lib, pkgs, ... }:

let cfg = config.cookie.qt;
in with lib; {
  options.cookie.qt = { enable = mkEnableOption "Enables Qt theming"; };

  config = mkIf cfg.enable {
    qt = {
      enable = true;
      style = "adwaita-dark";
      platformTheme = "gnome";
    };
  };
}
