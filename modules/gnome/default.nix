{ lib, config, pkgs, ... }:

let cfg = config.cookie.gnome;
in with lib; {
  options.cookie.gnome = {
    enable = mkEnableOption "Enables a bunch of GNOME apps";
  };
  config = mkIf cfg.enable {
    programs.dconf.enable = true;
    services.gvfs.enable = true;
    services.udev.packages = with pkgs; [ gnome-settings-daemon ];

    environment.systemPackages = with pkgs; [
      adwaita-icon-theme
      gnomeExtensions.appindicator
    ];

    # gnome-screenshot is used in multiple modules, across HM-NixOS boundaries, therefore..
    # update: it's only used in the old upload-to-i.ckie.dev script now, kinda redundant,
    # and it doesn't work right, but I'm keeping it around for now. TODO: remove it & refs, maim+xclip is better.
    nixpkgs.overlays = [
      (self: super: {
        gnome = super.gnome // {
          gnome-screenshot = super.gnome.gnome-screenshot.overrideAttrs (o: {
            patches = o.patches ++ [
              ./0001-screenshot-application.c-clipboard-cli-block-on-next.patch
            ];
          });
        };
      })
    ];

    services.gnome.gnome-keyring.enable =
      true; # HM also has a module but it cant configure pam, d-bus & co.

    home-manager.users.ckie = { pkgs, ... }: {
      home.packages = with pkgs; [
        file-roller
        gnome-system-monitor
        gnome-calculator
        gnome-disk-utility
        totem
        eog
        gnome-screenshot
        evince
      ];
    };
  };
}
