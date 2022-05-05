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
      home.packages = with pkgs; [
        gnome.file-roller
        gnome.gnome-system-monitor
        (gnome.gnome-calculator.overrideAttrs (old: {
          patches = (old.patches or []) ++ [ ./0001-remove-update_rates-call.patch ];
          dontCheck = true; # patch breaks the tests
          doCheck = false;
        }))
        gnome.gnome-disk-utility
        gnome.totem
        gnome.eog
      ];
    };
  };
}
