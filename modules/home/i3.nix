{ lib, config, pkgs, ... }:

let cfg = config.cookie.i3;
in with lib; {
  options.cookie.i3 = {
    enable = mkEnableOption "Enables the i3 window manager";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      rofi
      gnome3.gnome-screenshot
      kdeconnect
      libnotify # notify-send
      xclip
      feh
      xorg.xkill # if shit gets stuck
      pavucontrol
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
            {
              command = "${pkgs.kdeconnect}/bin/kdeconnect-indicator";
              notification = false;
            }
            {
              command = "${pkgs.networkmanagerapplet}/bin/nm-applet";
              notification = false;
            }
            {
              command = "${pkgs.feh}/bin/feh --no-fehbg --bg-scale ~/Sync/bg";
              notification = false;
            }
            {
              command = "${../../ext/i3-scripts/oszwatch}";
              notification = false;
            }
          ];
          bars = [ ];
          keybindings = with {
            modifier = config.xsession.windowManager.i3.config.modifier;
            spotifyWorkspace = "Spf";
            locker =
              "/run/wrappers/bin/slock"; # slock uses security.wrappers for setuid
          };
            lib.mkOptionDefault {
              # brightness & audio Fn keys
              "${modifier}+F1" = ''
                exec "${pkgs.alsaUtils}/bin/amixer set Master 1+ toggle && pkill -RTMIN+2 i3blocks"'';
              "${modifier}+F2" = ''
                exec "${pkgs.alsaUtils}/bin/amixer sset Master 5%- && pkill -RTMIN+2 i3blocks"'';
              "${modifier}+F3" = ''
                exec "${pkgs.alsaUtils}/bin/amixer sset Master 5%+ && pkill -RTMIN+2 i3blocks"'';
              "${modifier}+F4" = ''
                exec "${pkgs.playerctl}/bin/playerctl --player=firefox,vlc,spotify,%any next"'';
              "${modifier}+F5" = ''
                exec "${pkgs.brightnessctl}/bin/brightnessctl set 5%- && pkill -RTMIN+12 i3blocks"'';
              "${modifier}+F6" = ''
                exec "${pkgs.brightnessctl}/bin/brightnessctl set +5% && pkill -RTMIN+12 i3blocks"'';
              # old i3 defaults
              "${modifier}+Shift+f" = "floating toggle";
              # lock/suspend
              "--release ${modifier}+l" = "exec ${locker}";
              "--release ${modifier}+Shift+s" =
                ''exec "${locker} ${pkgs.systemd}/bin/systemctl suspend -i"'';
              # screenshot
              "--release ${modifier}+End" =
                "exec ${../../ext/i3-scripts/screenshot}";
              "--release ${modifier}+Pause" =
                "exec ${../../ext/i3-scripts/screenshot}";

              "--release ${modifier}+Shift+t" =
                "exec ${../../ext/i3-scripts/tntwars}";
              # "--release ${modifier}+Shift+d" =
              #   "exec ${config.xsession.windowManager.i3.config.terminal} ${
              #     ../i3-scripts/shall
              #   }";
              "--release ${modifier}+Shift+g" =
                "exec ${../../ext/i3-scripts/nixmenu}";
              "${modifier}+Shift+h" = "exec ${../../ext/i3-scripts/sinkswap}";

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
          menu =
            "${pkgs.rofi}/bin/rofi -show drun -terminal ${pkgs.kitty}/bin/kitty";
        };
      };
    };
  };
}
