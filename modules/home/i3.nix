{ builtins, lib, config, nixosConfig, pkgs, ... }:

let
  cfg = config.cookie.i3;
  desktopCfg = nixosConfig.cookie.desktop;
  musicWorkspace = "mpd";
  playerctl =
    "${pkgs.playerctl}/bin/playerctl --player=vlc,mpd,spotify,%any";
  startup = pkgs.writeScript "i3-startup" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.kdeconnect}/libexec/kdeconnectd &
    ${pkgs.kdeconnect}/bin/kdeconnect-indicator &
    ${pkgs.networkmanagerapplet}/bin/nm-applet &
    ${pkgs.feh}/bin/feh --no-fehbg --bg-scale ~/Sync/bg &
    ${../../ext/i3-scripts/oszwatch} &
    Discord &
    DiscordPTB &
    st -T weechat -e sh -c weechat &
    firefox &
    emacs &
    cantata &
  '';
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
            commands = [{
              command = "floating enable";
              criteria = { instance = "origin.exe"; };
            }];
          };
          startup = [{
            command = "${startup}";
            notification = false;
          }];
          bars = [ ];
          keybindings = with {
            modifier = config.xsession.windowManager.i3.config.modifier;
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
              "${modifier}+F4" = ''exec "${playerctl} next"'';
              "${modifier}+t" = ''exec "${playerctl} play-pause"'';
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
              "${modifier}+Shift+d" =
                "exec emacsclient -nc ~/Sync/org/scratchpad.org";
              "--release ${modifier}+Shift+g" =
                "exec ${../../ext/i3-scripts/nixmenu}";
              "${modifier}+Shift+h" = "exec ${../../ext/i3-scripts/sinkswap}";

              # music house
              "${modifier}+Shift+w" =
                "move container to workspace ${musicWorkspace}";
              "${modifier}+w" = "workspace ${musicWorkspace}";
              # force i3 to make 1 the starting workspace
              "F13" = "workspace 1";
              "F14" = "workspace 2";
            };
          assigns = {
            "1" = [{ class = "^Firefox$"; }];
            "2" = [ { class = "^discord"; } { title = "^weechat$"; } ];
            "4" = [{ class = "^Emacs$"; }];
            "${musicWorkspace}" = [{ class = "^cantata"; }];
          };
          fonts = [ "monospace 9" ];
          modifier = "Mod4"; # super key
          menu = "${pkgs.rofi}/bin/rofi -show drun";
        };
        extraConfig = mkIf (desktopCfg.secondaryMonitor != null) ''
          workspace 1 output ${desktopCfg.primaryMonitor}
          workspace 2 output ${desktopCfg.secondaryMonitor}
          workspace 3 output ${desktopCfg.primaryMonitor}
          workspace 4 output ${desktopCfg.primaryMonitor}
          workspace 5 output ${desktopCfg.primaryMonitor}
          workspace 6 output ${desktopCfg.primaryMonitor}
          workspace 7 output ${desktopCfg.primaryMonitor}
          workspace 8 output ${desktopCfg.primaryMonitor}
          workspace 9 output ${desktopCfg.primaryMonitor}
          workspace 10 output ${desktopCfg.primaryMonitor}
          workspace ${musicWorkspace} output ${desktopCfg.secondaryMonitor}
        '';
      };
    };
  };
}
