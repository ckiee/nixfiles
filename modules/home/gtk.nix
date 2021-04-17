{ lib, config, pkgs, ... }:

let cfg = config.cookie.gtk;
in with lib; {
  options.cookie.gtk = {
    enable = mkEnableOption "Enables some sexy GTK theming";
    darkTheme = mkOption {
      types = types.bool;
      description = "Enables the dark theme to save your eyes";
      default = true;
    };
  };

  gtk = mkIf cfg.enable {
    enable = true;
    iconTheme = {
      name = "Paper";
      package = pkgs.paper-gtk-theme;
    };
    gtk3.extraConfig = { gtk-application-prefer-dark-theme = cfg.darkTheme; };
  };
}
