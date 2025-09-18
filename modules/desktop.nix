{ config, lib, pkgs, ... }:

let cfg = config.cookie.desktop;
in with lib; {
  options.cookie.desktop = {
    enable = mkEnableOption "Cookie's desktop";
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

    wm = mkOption {
      type = types.nullOr (types.enum [ "i3" "sway" ]);
      default = "sway";
      description = "WM";
    };
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

    zramSwap.enable = true; # TODO: Move to tl /default.nix once verified good

    users.users.ckie.extraGroups = [ "adbusers" "libvirtd" "plugdev" ];

    environment.systemPackages = with pkgs;
      [
        #
        immich-cli
        tigervnc # using it for the client, vncviewer
        x11vnc # vnc server to unlock lightdm remotely, and maybe use the session too
        appimage-run
      ] ++ (if cfg.laptop then
        (with pkgs;
          [
            #
            acpi
          ])
      else
        [ ]);

    programs.nix-ld.enable = true;

    home-manager.users.ckie = { pkgs, ... }: {
      cookie = {
        polybar = {
          enable = cfg.wm == "i3";
          inherit (cfg) laptop;
        };
        gtk.enable = true;
        dunst.enable = true; # TODO replace..
        # fnott.enable = true;
        keyboard.enable = true;
        redshift.enable = cfg.wm == "i3";
        gammastep.enable = cfg.wm == "sway";
        nautilus.enable = true;
        i3.enable = cfg.wm == "i3";
        xcursor.enable = true;
        remotemacs.enable = true;
        mimeapps.enable = true;
        st.enable = true;
        screen-locker.enable = true;
        toot.enable = true;
        mangohud.enable = true;
        netintent.enable = true;
        ardour.enable = true;
        zathura.enable = true;
        taskwarrior.enable = true;
        waybar = {
          enable = cfg.wm == "sway";
          inherit (cfg) laptop;
        };
      };
      services.rsibreak.enable = cfg.wm == "i3";
    };

    programs = {
      adb.enable = true;
      gphoto2.enable = true;
    };
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
      xdgOpenUsePortal = true;
      config.common.default = "gtk";
    };

    cookie = {
      collections = {
        media.enable = true;
        chat.enable = true;
      };
      services = {
        avahi.enable = true;
        printing.enable = true;
        scanner.enable = true;
      };
      xserver.enable = true;
      sound = {
        enable = true;
        pipewire = { enable = mkDefault true; };
      };
      sway.enable = cfg.wm == "sway";
      slock.enable = cfg.wm == "sway";
      fonts.enable = true;
      gnome.enable = true;
      qt.enable = true;
      doom-emacs.enable = true;
      mpd.enable = true;
      cnping.enable = true;
      wireshark.enable = true;
      logiops.enable = true;
      apple-fastcharge.enable = true;
      keyd.enable = true;
    };

  };
}
