{ util, sources, lib, config, nixosConfig, pkgs, ... }:

with lib;
with builtins;

let
  inherit (util) mkRequiresScript;

  cfg = config.cookie.i3;
  desktopCfg = nixosConfig.cookie.desktop;
  musicWorkspace = "mpd";
  mpc = "${pkgs.mpc_cli}/bin/mpc";
in {
  options.cookie.i3 = { enable = mkEnableOption "i3 window manager"; };

  imports = [ ./auxapps.nix ./as-systemd.nix ];
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
      (firefox.override { cfg.speechSynthesisSupport = true; })
      calibre # ebook reader
      friture # voice shenanigans (:
      # nottetris2
      virt-manager # connect to vms on the net
      (wrapOBS { plugins = with obs-studio-plugins; [ obs-vaapi ]; })
      sidequest # mediocre vr
      transmission_4-gtk # capitalism
      blockbench-electron # placing blocks
      krita # drawing
      # prusa-slicer # making things out of harmful plastic
      # subtitleeditor # making text from sine waves, manually # TODO unbreak package
      # freecad # behold our most precious polygons, just one step away from real life!
      easytag # too bad you can't tag easytag with easytag.. ID3 everywhere?
      screenkey # show the keyboard keys on the ~~keyboard~~screen
      linthesia # musicy music play piano
      chromium # sucks, ik, but need it sometimes..
      x11vnc # vnc server to unlock lightdm remotely, and maybe use the session too
      tigervnc # using it for the client, vncviewer
      onlyoffice-bin # ms office clone! works well for english-only things.
      (minimeters.overrideAttrs (prev: {
        src = ../../../secrets/minimeters-0.8.8.zip;
        preInstall = import ../../../secrets/minimeters-shush-update.nix;
      }))
    ];
    cookie.polyprog.enable = true;

    xsession = {
      # umm.. nothing here..
      # (we use PATH to share some things between modules, see
      # windowManager.i3.config.terminal="st" for example)
      importedVariables = [
        "PATH"
        "DISPLAY"
        "NIX_PROFILES" # nixpkgs ardour7 uses this at runtime
      ];

      enable = true;
      windowManager.i3 = {
        enable = true;
        config = {
          # HACK: previously i3 ran in the existing environ of a
          # login shell, but systemd-ification took that away, so..
          # uhm.. there :)
          terminal = "st bash --login";
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
          bars = [ ];
          keybindings = with {
            modifier = config.xsession.windowManager.i3.config.modifier;
            locker =
              "/run/wrappers/bin/slock"; # slock uses security.wrappers for setuid
            pam = "exec ${pkgs.pamixer}/bin/pamixer";
            screenie = let
              s = a:
                "exec " + (pkgs.writeShellScript "i3-screenshot-maim-wrapper"
                  "${pkgs.maim}/bin/maim --hidecursor ${a} | ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png");
            in {
              area = s "-s";
              window = s "-i $(${pkgs.xdotool}/bin/xdotool getactivewindow)";
            };
          };
            mkMerge [
              (import ./defaults.nix {
                cfg = config.xsession.windowManager.i3;
              })
              {
                # brightness & audio Fn keys
                "${modifier}+F1" = "${pam} --toggle-mute";
                "${modifier}+F2" = "${pam} --decrease 5";
                "${modifier}+F3" = "${pam} --increase 5";
                "${modifier}+F4" = ''exec "${mpc} next"'';
                "${modifier}+t" = ''exec "${mpc} toggle"'';
                # These two XF86Audio* ones are used by some bluetooth headphones,
                # including our WH-1000XM4's which manage to get forwarded by
                # x2x to cookiemonster, even when they're connected to thonkcookie.
                #
                # Scary.
                "XF86AudioPlay" = ''exec "${mpc} play"'';
                "XF86AudioPause" = ''exec "${mpc} pause"'';
                #
                "${modifier}+F5" =
                  ''exec "${pkgs.brightnessctl}/bin/brightnessctl set 5%-"'';
                "${modifier}+F6" =
                  ''exec "${pkgs.brightnessctl}/bin/brightnessctl set +5%"'';
                # old i3 defaults
                "${modifier}+Shift+f" = "floating toggle";
                # new i3 native func bind. https://i3wm.org/docs/userguide.html#_sticky_floating_windows
                "${modifier}+Shift+v" = "sticky toggle";
                # lock/suspend
                "--release ${modifier}+l" = "exec ${locker}";
                "--release ${modifier}+Shift+s" =
                  ''exec "${locker} ${pkgs.systemd}/bin/systemctl suspend -i"'';
                # kill the whole sysd session
                "${modifier}+Shift+e" =
                  "exec i3-nagbar -t warning -m 'Do you want to exit the session?' -b 'Yes' 'systemctl --user stop hm-graphical-session.target'";

                # screenshot
                "--release ${modifier}+End" = screenie.area;
                "--release ${modifier}+Pause" = screenie.area;
                "--release ${modifier}+Shift+End" = screenie.window;
                "--release ${modifier}+Shift+Pause" = screenie.window;

                "--release ${modifier}+Shift+t" =
                  "exec ${mkRequiresScript ./scripts/tntwars}";
                "${modifier}+Shift+d" =
                  "exec emacsclient -nc ~/Sync/org/scratchpad.org";
                "--release ${modifier}+Shift+g" =
                  "exec ${mkRequiresScript ./scripts/nixmenu}";
                "${modifier}+Shift+h" =
                  "exec ${mkRequiresScript ./scripts/sinkswap}";
                "${modifier}+Shift+b" =
                  "exec ${mkRequiresScript ./scripts/showerset}";

                # fmouse
                # "${modifier}+a" = "exec ${pkgs.fmouse}/bin/fmouse";
                # "${modifier}+Shift+a" = "exec ${pkgs.fmouse}/bin/fmouse --right-click";

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
                "${modifier}+Control+Shift+1" =
                  "move container to workspace °1";
                "${modifier}+Control+Shift+2" =
                  "move container to workspace °2";
                "${modifier}+Control+Shift+3" =
                  "move container to workspace °3";
                "${modifier}+Control+Shift+4" =
                  "move container to workspace °4";
                "${modifier}+Control+Shift+5" =
                  "move container to workspace °5";
                "${modifier}+Control+Shift+6" =
                  "move container to workspace °6";
                "${modifier}+Control+Shift+7" =
                  "move container to workspace °7";
                "${modifier}+Control+Shift+8" =
                  "move container to workspace °8";
                "${modifier}+Control+Shift+9" =
                  "move container to workspace °9";
                "${modifier}+Control+Shift+0" =
                  "move container to workspace °10";
              }
            ];

          assigns = {
            "1" = [{ class = "^Firefox$"; }];
            "2" = [
              { class = "^discord"; }
              { title = "^weechat$"; }
              { class = "^Element"; }
              { class = "^SchildiChat"; }
              { class = "^nheko"; }
            ];
            "4" = [{ class = "^Emacs$"; }];
            "5" = [{ class = "ledc"; }];
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
