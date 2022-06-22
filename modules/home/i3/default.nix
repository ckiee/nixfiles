{ util, sources, lib, config, nixosConfig, pkgs, ... }:

with lib;
with builtins;

let
  inherit (util) mkRequiresScript;

  cfg = config.cookie.i3;
  desktopCfg = nixosConfig.cookie.desktop;
  musicWorkspace = "mpd";
  mpc = "${pkgs.mpc_cli}/bin/mpc";
  startup = pkgs.writeScript "i3-startup" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.kdeconnect}/libexec/kdeconnectd &
    ${pkgs.kdeconnect}/bin/kdeconnect-indicator &
    ${pkgs.networkmanagerapplet}/bin/nm-applet &
    ${pkgs.feh}/bin/feh --no-fehbg --bg-scale ${./backgrounds/solid} &
    ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &
    ${mkRequiresScript ./scripts/oszwatch} &
    ${mkRequiresScript ./scripts/musicwatch} &
    # fractal &
    Discord &
    element-desktop &
    # DiscordPTB &
    st -T weechat -e sh -c weechat &
    firefox &
    cantata &
  '';
in {
  options.cookie.i3 = {
    enable = mkEnableOption "Enables the i3 window manager";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      rofi
      kdeconnect
      libnotify # notify-send
      xclip
      feh
      xorg.xkill # if shit gets stuck
      arandr
      pavucontrol
      audacity
      firefox
      calibre
      friture # voice shenanigans (:
      # nottetris2
      virt-manager # connect to vms on the net
      obs-studio
      sidequest # mediocre vr
      transmission-gtk # capitalism
      blockbench-electron # placing blocks
      krita # drawing
      prusa-slicer # making things out of harmful plastic
      ardour # piano
      # subtitleeditor # making text from sine waves, manually # TODO unbreak package
      # freecad # behold our most precious polygons, just one step away from real life!
      easytag # too bad you can't tag easytag with easytag.. ID3 everywhere?
      screenkey # show the keyboard keys on the ~~keyboard~~screen
      linthesia # musicy music play piano
    ];
    cookie.polyprog.enable = true; # Required for the ytm bind

    xsession = {
      enable = true;
      windowManager.i3 = {
        enable = true;
        config = {
          terminal = "st";
          gaps = {
            inner = 2;
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
            pam = "exec ${pkgs.pamixer}/bin/pamixer";
          };
            lib.mkOptionDefault {
              # brightness & audio Fn keys
              "${modifier}+F1" = "${pam} --toggle-mute";
              "${modifier}+F2" = "${pam} --decrease 5";
              "${modifier}+F3" = "${pam} --increase 5";
              "${modifier}+F4" = ''exec "${mpc} next"'';
              "${modifier}+t" = ''exec "${mpc} toggle"'';
              "${modifier}+F5" =
                ''exec "${pkgs.brightnessctl}/bin/brightnessctl set 5%-"'';
              "${modifier}+F6" =
                ''exec "${pkgs.brightnessctl}/bin/brightnessctl set +5%"'';
              # old i3 defaults
              "${modifier}+Shift+f" = "floating toggle";
              # lock/suspend
              "--release ${modifier}+l" = "exec ${locker}";
              "--release ${modifier}+Shift+s" =
                ''exec "${locker} ${pkgs.systemd}/bin/systemctl suspend -i"'';
              # screenshot
              "--release ${modifier}+End" =
                "exec ${mkRequiresScript ./scripts/screenshot}";
              "--release ${modifier}+Pause" =
                "exec ${mkRequiresScript ./scripts/screenshot}";

              "--release ${modifier}+Shift+t" =
                "exec ${mkRequiresScript ./scripts/tntwars}";
              "${modifier}+Shift+d" =
                "exec emacsclient -nc ~/Sync/org/scratchpad.org";
              "--release ${modifier}+Shift+g" =
                "exec ${mkRequiresScript ./scripts/nixmenu}";
              "${modifier}+Shift+h" = "exec ${mkRequiresScript ./scripts/sinkswap}";
              "${modifier}+Shift+b" = "exec ${mkRequiresScript ./scripts/showerset}";

              # fmouse
              "${modifier}+a" = "exec ${pkgs.fmouse}/bin/fmouse";
              "${modifier}+Shift+a" = "exec ${pkgs.fmouse}/bin/fmouse --right-click";

              # music house
              "${modifier}+Shift+w" =
                "move container to workspace ${musicWorkspace}";
              "${modifier}+w" = "workspace ${musicWorkspace}";
              # force i3 to make 1 the starting workspace
              "F13" = "workspace 1";
              "F14" = "workspace 2";
              # another 10 workspaces for the 2nd monitor
              "${modifier}+Control+1" = "workspace °1";
              "${modifier}+Control+2" = "workspace °2";
              "${modifier}+Control+3" = "workspace °3";
              "${modifier}+Control+4" = "workspace °4";
              "${modifier}+Control+5" = "workspace °5";
              "${modifier}+Control+6" = "workspace °6";
              "${modifier}+Control+7" = "workspace °7";
              "${modifier}+Control+8" = "workspace °8";
              "${modifier}+Control+9" = "workspace °9";
              "${modifier}+Control+0" = "workspace °10";
              ## the move container to $ws
              "${modifier}+Control+Shift+1" = "move container to workspace °1";
              "${modifier}+Control+Shift+2" = "move container to workspace °2";
              "${modifier}+Control+Shift+3" = "move container to workspace °3";
              "${modifier}+Control+Shift+4" = "move container to workspace °4";
              "${modifier}+Control+Shift+5" = "move container to workspace °5";
              "${modifier}+Control+Shift+6" = "move container to workspace °6";
              "${modifier}+Control+Shift+7" = "move container to workspace °7";
              "${modifier}+Control+Shift+8" = "move container to workspace °8";
              "${modifier}+Control+Shift+9" = "move container to workspace °9";
              "${modifier}+Control+Shift+0" = "move container to workspace °10";
            };
          assigns = {
            "1" = [{ class = "^Firefox$"; }];
            "2" = [
              { class = "^discord"; }
              { title = "^weechat$"; }
              { class = "^Element"; }
            ];
            "4" = [{ class = "^Emacs$"; }];
            "${musicWorkspace}" = [{ class = "^cantata"; }];
          };
          fonts = {
            names = [ "monospace" ];
            size = 9.0;
          };
          modifier = "Mod4"; # super key
          menu = "${pkgs.rofi}/bin/rofi -show drun";
        };
        extraConfig = mkIf (desktopCfg.monitors != null
          && desktopCfg.monitors.secondary != null) ''
            workspace 1 output ${desktopCfg.monitors.primary}
            workspace 2 output ${desktopCfg.monitors.secondary}
            workspace 3 output ${desktopCfg.monitors.primary}
            workspace 4 output ${desktopCfg.monitors.primary}
            workspace 5 output ${desktopCfg.monitors.primary}
            workspace 6 output ${desktopCfg.monitors.primary}
            workspace 7 output ${desktopCfg.monitors.primary}
            workspace 8 output ${desktopCfg.monitors.primary}
            workspace 9 output ${desktopCfg.monitors.primary}
            workspace 10 output ${desktopCfg.monitors.primary}
            workspace ${musicWorkspace} output ${desktopCfg.monitors.secondary}
            workspace °1 output ${desktopCfg.monitors.secondary}
            workspace °2 output ${desktopCfg.monitors.secondary}
            workspace °3 output ${desktopCfg.monitors.secondary}
            workspace °4 output ${desktopCfg.monitors.secondary}
            workspace °5 output ${desktopCfg.monitors.secondary}
            workspace °6 output ${desktopCfg.monitors.secondary}
            workspace °7 output ${desktopCfg.monitors.secondary}
            workspace °8 output ${desktopCfg.monitors.secondary}
            workspace °9 output ${desktopCfg.monitors.secondary}
            workspace °10 output ${desktopCfg.monitors.secondary}
          '';
      };
    };
  };
}
