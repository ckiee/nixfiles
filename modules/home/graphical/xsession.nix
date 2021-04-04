{ config, lib, pkgs, ... }: {
  home.packages = with pkgs; [
    i3blocks
    acpi # util for i3blocks battery info
    brightnessctl
    rofi
    dunst
    gnome3.gnome-screenshot
    picom
    redshift
    kdeconnect
    libnotify # notify-send
    xclip
    networkmanagerapplet
    sysstat
    feh
    xorg.xkill # if shit gets stuck
    # apps
    pavucontrol
    gnome3.nautilus
    gnome3.gvfs # nautilus likes this!
    gnome3.file-roller
    gnome3.gnome-system-monitor
    gnome3.gnome-calculator
    wakatime # i only code on graphical machines so here it is
  ];

  xsession = {
    enable = true;
    windowManager.i3 = {
      enable = true;
      config = {
        gaps = {
          inner = 10;
          outer = 0;
          smartGaps = true;
        };
        window = {
          border = 0;
          titlebar = false;
        };
        startup = [
          {
            command =
              "${pkgs.kdeconnect}/libexec/kdeconnectd"; # when dbus automatically launches kdeconnectd things get weird
            notification = false;
          }
          { command = "${pkgs.kdeconnect}/bin/kdeconnect-indicator"; }
          { command = "${pkgs.feh}/bin/feh --no-fehbg --bg-scale ~/Sync/bg"; }
          {
            command = "${../i3-scripts/oszwatch}";
            notification = false;
          }
        ];
        bars = [{
          statusCommand = "i3blocks";
          fonts =
            config.xsession.windowManager.i3.config.fonts; # set to the root fonts
        }];
        keybindings = with {
          modifier = config.xsession.windowManager.i3.config.modifier;
          spotifyWorkspace = "Spf";
          locker =
            "/run/wrappers/bin/slock"; # slock uses security.wrappers for setuid
        };
          lib.mkOptionDefault {
            # brightness & audio Fn keys
            "XF86MonBrightnessUp" = ''
              exec "${pkgs.brightnessctl}/bin/brightnessctl set +5% && pkill -RTMIN+12 i3blocks"'';
            "XF86MonBrightnessDown" = ''
              exec "${pkgs.brightnessctl}/bin/brightnessctl set 5%- && pkill -RTMIN+12 i3blocks"'';
            "${modifier}+F1" = ''
              exec "${pkgs.alsaUtils}/bin/amixer set Master 1+ toggle && pkill -RTMIN+2 i3blocks"'';
            "${modifier}+F2" = ''
              exec "${pkgs.alsaUtils}/bin/amixer sset Master 5%- && pkill -RTMIN+2 i3blocks"'';
            "${modifier}+F3" = ''
              exec "${pkgs.alsaUtils}/bin/amixer sset Master 5%+ && pkill -RTMIN+2 i3blocks"'';
            "${modifier}+F4" = ''
              exec "${pkgs.playerctl}/bin/playerctl --player=vlc,spotify,%any next"'';
            # old i3 defaults
            "${modifier}+Shift+f" = "floating toggle";
            # lock/suspend
            "--release ${modifier}+l" = "exec ${locker}";
            "--release ${modifier}+Shift+s" =
              ''exec "${locker} ${pkgs.systemd}/bin/systemctl suspend -i"'';
            # screenshot
            "--release ${modifier}+End" = "exec ${../i3-scripts/screenshot}";
            "--release ${modifier}+Pause" = "exec ${../i3-scripts/screenshot}";

            "--release ${modifier}+Shift+t" = "exec ${../i3-scripts/tntwars}";
            # "--release ${modifier}+Shift+d" =
            #   "exec ${config.xsession.windowManager.i3.config.terminal} ${
            #     ../i3-scripts/shall
            #   }";
            "--release ${modifier}+Shift+g" = "exec ${../i3-scripts/nixmenu}";
            "${modifier}+Shift+h" = "exec ${../i3-scripts/sinkswap}";

            # spotify's house
            "${modifier}+Shift+w" =
              "move container to workspace ${spotifyWorkspace}";
            "${modifier}+w" = "workspace ${spotifyWorkspace}";
            # force i3 to make 1 the starting workspace
            "F13" = "workspace 1";
            "F14" = "workspace 2";
          };
        fonts = [ "monospace 9" ];
        modifier = "Mod4"; # super key
        terminal = "${pkgs.kitty}/bin/kitty";
        menu =
          "${pkgs.rofi}/bin/rofi -show drun -terminal ${pkgs.kitty}/bin/kitty";
      };
    };
  };
}
