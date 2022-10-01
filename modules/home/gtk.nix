{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.gtk;
  gtkConfig = {
    extraConfig = { gtk-application-prefer-dark-theme = cfg.darkTheme; };
  };
in with lib; {
  options.cookie.gtk = {
    enable = mkEnableOption "Enables some sexy GTK theming";
    darkTheme = mkOption {
      type = types.bool;
      description = "Enables the dark theme to save your eyes";
      default = true;
    };
  };

  config.gtk = mkIf cfg.enable {
    enable = true;
    iconTheme = {
      name = "breeze-dark";
      package = pkgs.breeze-icons;
    };
    gtk3 = gtkConfig;
    gtk4 = gtkConfig;
  };
}
