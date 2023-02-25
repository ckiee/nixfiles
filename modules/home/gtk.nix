{ lib, config, pkgs, ... }:

with lib;

let cfg = config.cookie.gtk;
in {
  options.cookie.gtk = {
    enable = mkEnableOption "Enables some sexy GTK theming";
    darkTheme = mkOption {
      type = types.bool;
      description = "Enables the dark theme to save your eyes";
      default = true;
    };
  };

  config = mkIf cfg.enable {
    gtk = {
      enable = true;
      iconTheme = {
        name = "Paper";
        package = pkgs.paper-gtk-theme;
      };
      gtk3 = {
        extraConfig = { gtk-application-prefer-dark-theme = cfg.darkTheme; };
      };
    };

    dconf.settings."org/gnome/desktop/interface" = {
      # GTK 4:
      color-scheme = "prefer-dark";
    };
  };
}
