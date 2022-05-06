{ lib, config, pkgs, ... }:

let cfg = config.cookie.xcursor;
in with lib; {
  options.cookie.xcursor = {
    enable = mkEnableOption "Enables a better-looking mouse cursor";
  };

  config = mkIf cfg.enable {
    home.pointerCursor = {
      package = pkgs.gnome3.adwaita-icon-theme;
      name = "Adwaita";
      size = 16;
      x11.enable = true;
      gtk.enable = true;
    };
  };
}
