{ config, lib, pkgs, ... }:

let cfg = config.cookie.desktop;
in with lib; {
  options.cookie.desktop = {
    enable = mkEnableOption "Enables the Cookie's desktop";
    # These are used by home/i3.nix, home/polybar.nix
    monitors = mkOption {
      type = types.nullOr (types.submodule {
        options = {
          primary = mkOption {
            type = types.str;
            example = "eDP-1";
            description = "primary output";
          };
          secondary = mkOption {
            type = types.nullOr types.str;
            example = "eDP-1";
            description = "secondary output";
            default = null;
          };
        };
      });
      description = "monitor configuration";
      default = null;
    };
    laptop = mkEnableOption "Enables laptop-specific customizations";
  };

  config = mkIf cfg.enable {
    # Supposedly this build is better for desktop users
    # TODO uncomment once zen is patched for btrfs breakage
    # boot.kernelPackages = pkgs.linuxPackages_zen;

    # Hackity HACK for working D-Bus activation
    systemd.user.services.dbus.environment.DISPLAY = ":0";

    # Users will do scary things and suddenly require more memory,
    # so let's take a bunch of spares from the cache so we don't OOM
    # as easily.
    boot.kernel.sysctl = {
      "vm.user_reserve_kbytes" = 196608; # 1(2^17)
      "vm.admin_reserve_kbytes" = 65536; # 0.5(2^17)
    };

    home-manager.users.ckie = { pkgs, ... }: {
      cookie = {
        polybar = {
          enable = true;
          inherit (cfg) laptop;
        };
        gtk.enable = true;
        dunst.enable = true;
        keyboard.enable = true;
        redshift.enable = true;
        nautilus.enable = true;
        i3.enable = true;
        xcursor.enable = true;
        remotemacs.enable = true;
        mimeapps.enable = true;
        st.enable = true;
        screen-locker.enable = true;
        toot.enable = true;
        mangohud.enable = true;
        netintent.enable = true;
        fmouse.enable = true;
        ardour.enable = true;
      };
      services.rsibreak.enable = true;
    };
    cookie = {
      collections = { media.enable = true; chat.enable = true; };
      services = {
        avahi.enable = true;
        printing.enable = true;
        scanner.enableClient = true;
      };
      xserver.enable = true;
      sound = {
        enable = true;
        pipewire = { enable = mkDefault true; };
      };
      slock.enable = true;
      fonts.enable = true;
      gnome.enable = true;
      qt5.enable = true;
      doom-emacs.enable = true;
      mpd.enable = true;
    };
  };
}
