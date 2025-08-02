{ util, sources, lib, config, pkgs, ... }:

with lib;
with builtins;

let
  inherit (util) mkRequiresScript;

  cfg = config.cookie.sway;
  desktopCfg = config.cookie.desktop;
  musicWorkspace = "mpd";
  mpc = "${pkgs.mpc_cli}/bin/mpc";
in {
  options.cookie.sway = { enable = mkEnableOption "sway window manager"; };

  imports = [ ./auxapps.nix ];
  config = mkIf cfg.enable {
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      package = with pkgs;
        sway.override { sway-unwrapped = enableDebugging sway-unwrapped; };
      extraSessionCommands = ''
        # SDL:
        export SDL_VIDEODRIVER=wayland
        # QT (needs qt5.qtwayland in systemPackages):
        export QT_QPA_PLATFORM=wayland-egl
        export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
        # Fix for some Java AWT applications (e.g. Android Studio),
        # use this if they aren't displayed properly:
        export _JAVA_AWT_WM_NONREPARENTING=1
        # some electrons via nixpkgs
        export NIXOS_OZONE_WL=1
        # darktable, but generally gtk..
        export GDK_BACKEND=wayland
      '';
    };

    home-manager.users.ckie = { config, ... }: {
      home.packages = with pkgs; [
        rofi-wayland
        plasma5Packages.kdeconnect-kde
        libnotify # notify-send
        xclip
        feh
        xorg.xkill # if shit gets stuck
        pavucontrol
        audacity
        (hiPrio tenacity) # audacity fork!
        (firefox.override { cfg.speechSynthesisSupport = true; })
        calibre # ebook reader
        # friture # voice shenanigans (: -- yet another spectrogram/metering program
        # nottetris2
        virt-manager # connect to vms on the net
        (wrapOBS { plugins = with obs-studio-plugins; [ obs-vaapi ]; })
        sidequest # mediocre vr
        transmission_4-gtk # capitalism
        # blockbench-electron # placing blocks
        krita # drawing
        inkscape # svg vectory drawing
        # prusa-slicer # making things out of harmful plastic
        # subtitleeditor # making text from sine waves, manually # TODO unbreak package
        # freecad # behold our most precious polygons, just one step away from real life!
        easytag # too bad you can't tag easytag with easytag.. ID3 everywhere?
        screenkey # show the keyboard keys on the ~~keyboard~~screen
        linthesia # musicy music play piano
        chromium # sucks, ik, but need it sometimes..
        libreoffice
        (minimeters.overrideAttrs (prev: {
          src = ../../secrets/minimeters-0.8.8.zip;
          preInstall = import ../../secrets/minimeters-shush-update.nix;
        }))
        anki
        scrcpy # Android screen cast
        uxplay # iOS screen mirroring (drag right down for control panel icon)
        bitwarden-desktop
        alsa-scarlett-gui
        darktable
        sony-headphones-client
        peek # mini screenrecorder
        xorg.xmodmap
        emote
        wl-clipboard
        cliphist
        grim
        slurp
        nwg-displays # the sway arandr
        wayvnc
        comical # cbz comic reader
      ];

      cookie.polyprog.enable = true;

      wayland.windowManager.sway = {
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

          focus = { wrapping = "yes"; };

          window = {
            border = 0;
            titlebar = false;
            commands = [{
              command = "floating enable";
              criteria = { instance = "origin.exe"; };
            }];
          };

          bars = [ ];

          input = {
            "type:keyboard" = {
              xkb_layout = "us,il";
              xkb_options = "grp:win_space_toggle,compose:rctrl,caps:super";
            };
            "*" = { # pointer, touchpad
              accel_profile = "flat";
              middle_emulation = "enabled";
            };
            "type:touchpad" = {
              drag = "enabled";
              tap = "enabled";
              natural_scroll = "enabled";
            };
            # "1133:16514:Logitech_MX_Master_3" = {
            #   pointer_accel = "0.4";
            # };
          };

          output = {
            "*" = { bg = "${./backgrounds/lain} fit"; };
            ${desktopCfg.monitors.primary} = { pos = "0 0"; };

            ${desktopCfg.monitors.secondary or "unreachable"} =
              mkIf (desktopCfg.monitors.secondary != null) { pos = "1920 0"; };
          };

          modes =
            let scfg = config.wayland.windowManager.sway.config;
              modifier = scfg.modifier;
            in {
              passthrough = {
                "${modifier}+Shift+Escape" =
                  "mode default; floating_modifier ${modifier} normal";
              };

              resize = {
                "${scfg.left}" = "resize shrink width 10 px";
                "${scfg.down}" = "resize grow height 10 px";
                "${scfg.up}" = "resize shrink height 10 px";
                "${scfg.right}" = "resize grow width 10 px";
                "Left" = "resize shrink width 10 px";
                "Down" = "resize grow height 10 px";
                "Up" = "resize shrink height 10 px";
                "Right" = "resize grow width 10 px";
                "Escape" = "mode default";
                "Return" = "mode default";
              };
            };

          keybindings = with {
            modifier = config.wayland.windowManager.sway.config.modifier;
            pam = "exec ${pkgs.pamixer}/bin/pamixer";
            screenie = {
              area = "exec slurp | grim -g - - | wl-copy";
              window = "exec ${
                  pkgs.writeShellScript "sway-scrot-window" ''
                    swaymsg -t get_tree | jq -r '.. | select(.focused?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | grim -g - - | wl-copy''
                }";
            };
          };
            mkMerge [
              (import ./defaults.nix {
                cfg = config.wayland.windowManager.sway;
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
                "XF86AudioNext" = ''exec "${mpc} next"'';
                "XF86AudioPrev" = ''exec "${mpc} prev"'';

                #
                "${modifier}+F5" =
                  ''exec "${pkgs.brightnessctl}/bin/brightnessctl set 5%-"'';
                "${modifier}+F6" =
                  ''exec "${pkgs.brightnessctl}/bin/brightnessctl set +5%"'';
                # old i3 defaults
                "${modifier}+Shift+f" = "floating toggle";
                "${modifier}+Shift+v" = "sticky toggle";
                # lock/suspend
                "--release ${modifier}+l" = "exec swaylock";
                "--release ${modifier}+Shift+s" =
                  ''exec "${pkgs.systemd}/bin/systemctl suspend -i"'';
                # kill the whole sysd session
                "${modifier}+Shift+e" =
                  "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -B 'Yes, exit sway' 'swaymsg exit'";
                # ssh into tmux-taboo
                "${modifier}+Shift+Return" = "exec st ssh cookiemonster";
                # clipboard history
                "${modifier}+c" = "exec ${
                    pkgs.writeShellScript "cliphist-for-sway"
                    "cliphist list | rofi -dmenu | cliphist decode | wl-copy "
                  }";
                # passthrough mode
                "${modifier}+Shift+F1" =
                  "mode passthrough; floating_modifier none";

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

                # notifications
                "${modifier}+Shift+space" = mkForce "exec dunstctl close";
                # "control+shift+space" = "exec dunstctl close-all";
                "${modifier}+grave" = "exec dunstctl history-pop";

                # music house
                "${modifier}+Shift+w" =
                  "move container to workspace ${musicWorkspace}";
                "${modifier}+w" = "workspace ${musicWorkspace}";
                # force sway to make 1 the starting workspace
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
              { class = "^slack"; }
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
          menu =
            "${pkgs.rofi-wayland}/bin/rofi -show drun -show-icons -font 'sans-serif 14'";
        };

        extraConfig = ''
          include /etc/sway/config.d/*
          exec "systemctl --user import-environment PATH"
          hide_edge_borders --i3 smart_no_gaps

          for_window [window_role = "pop-up"] floating enable
          for_window [window_role = "bubble"] floating enable
          for_window [window_role = "dialog"] floating enable
          for_window [window_type = "dialog"] floating enable
          for_window [window_role = "task_dialog"] floating enable
          for_window [window_type = "menu"] floating enable
          for_window [app_id = "floating"] floating enable
          for_window [app_id = "floating_update"] floating enable, resize set width 1000px height 600px
          for_window [class = "(?i)pinentry"] floating enable
          for_window [title = "Administrator privileges required"] floating enable

          ${optionalString (desktopCfg.monitors != null
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
            ''}
        '';
      };
    };
  };
}
