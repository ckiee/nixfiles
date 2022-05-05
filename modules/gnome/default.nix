{ lib, config, pkgs, ... }:

let cfg = config.cookie.gnome;
in with lib; {
  options.cookie.gnome = {
    enable = mkEnableOption "Enables a bunch of GNOME apps";
  };
  config = mkIf cfg.enable {
    programs.dconf.enable = true;
    services.gvfs.enable = true;
    services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

    environment.systemPackages = with pkgs; [
      gnome.adwaita-icon-theme
      gnomeExtensions.appindicator
    ];

    home-manager.users.ckie = { pkgs, ... }: {
      home.packages = with pkgs.gnome3; [
        file-roller
        gnome-system-monitor
        gnome-calculator
        gnome-disk-utility
        totem
        eog
      ];
    };
  };
}
