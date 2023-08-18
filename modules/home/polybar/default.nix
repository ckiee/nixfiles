{ util, config, lib, pkgs, nixosConfig, ... }:

let
  inherit (lib)
    optionals mkIf mkEnableOption mkOption types concatStrings optional
    optionalString mkMerge;
  inherit (util) mkRequiresScript;

  colors = {
    primary = "#ed60ba";
    alert = "#ffe261";
    bg-lighter = "#5f5f5f";
    bg-light = "#27212e";
    bg-dark = "#171717";
    black = "#000000";
  };
  base = {
    width = "100%";
    height = 20;
    bottom = true;
    radius = 0;

    font-0 = "JetBrains Mono:size=9";
    font-1 = "Noto Sans Mono CJK HK:size=9";
    font-2 = "Noto Sans Mono CJK JP:size=9";
    font-3 = "Noto Sans Mono CJK KR:size=9";
    font-4 = "Font Awesome 5 Free:style=Solid:size=9";
    font-5 = "Noto Color Emoji:size=9";

    scroll-up = "#ws.prev";
    scroll-down = "#ws.next";

    # module-margin-left = 1;
    # module-margin-right = 2;

    background = colors.bg-dark;
  };

  icons = {
    address-book = "";
    volume = "";
    memory = "";
    server = "";
    microchip = "";
    volume-off = "";
    volume-down = "";
    volume-up = "";
    volume-mute = "";
    sun = "";
    battery-full = "";
    globe = "";
    music = "";
    shower = "";
  };
  cfg = config.cookie.polybar;
  desktopCfg = nixosConfig.cookie.desktop;
  soundCfg = nixosConfig.cookie.sound;
  pkg = config.services.polybar.package;
in {

  options.cookie.polybar = {
    enable = mkEnableOption "Enables Polybar";
    laptop = mkEnableOption "Enables laptop-specific reporting";
    backlight = mkOption rec {
      type = types.nullOr types.str;
      default = null;
      description =
        "Exposes an optional backlight control of card `cfg.backlight` to the user if non-null";
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services = mkMerge (map (screen: {
      "polybar-${screen}" = {
        Unit = {
          Description = "Polybar status bar ${screen}";
          PartOf = [ "tray.target" ];
          After = [ "graphical-session.target" "i3wm.service" ];
          X-Restart-Triggers =
            [ "${config.xdg.configFile."polybar/config.ini".source}" ];
        };

        Service = {
          ExecStart = "${pkg}/bin/polybar ${screen}";
          Restart = "always";
        };

        Install = { WantedBy = [ "tray.target" ]; };
      };
    }) ([ "main" ] ++ optional
      (desktopCfg.monitors != null && desktopCfg.monitors.secondary != null)
      "side"));

    xdg.configFile."polybar/config.ini".onChange =
      "${pkgs.procps}/bin/pkill polybar";
    services.polybar = {
      enable = true;
      package = (pkgs.polybar.override {
        i3Support = true;
        pulseSupport = true;
        mpdSupport = true;
      }).overrideAttrs (old: {
        patches = old.patches
          ++ [ ./0001-feat-xkeyboard-add-shortname-token.patch ];
      });

      # we have our own per-bar systemd units
      script = "";

      config = {
        "bar/main" = base // {
          monitor = # only specify if needed; keep ext displays working on single-display machines
            mkIf (desktopCfg.monitors != null && desktopCfg.monitors.secondary
              != null) desktopCfg.monitors.primary;

          modules-left = "ws";
          modules-right =
            [ "prom" "separator" "polyprog" "mpd" "separator" "shower" ]
            ++ optionals (soundCfg.pipewire.enable || soundCfg.pulse.enable) [
              "separator"
              "volume"
            ] ++ [
              "separator"
              "memory"
              "small-spacer"
              "cpu"
              "separator"
              "keyboard"
            ] ++ optionals (cfg.backlight != null) [
              "separator"
              "backlight" # currently desktop also has ext. display brightness control (for the primary monitor only!)
            ] ++ optionals cfg.laptop [ "separator" "battery" ]
            ++ [ "separator" "date" "small-spacer" "time" "separator" ];

          tray-position = "right";
          tray-padding = 0;

          # For module/polyprog
          enable-ipc = true;
        };

        "bar/side" = mkIf
          (desktopCfg.monitors != null && desktopCfg.monitors.secondary != null)
          (base // {
            monitor = desktopCfg.monitors.secondary;

            modules-left = [ "ws" "separator" "time" "small-spacer" "date" ];
          });

        ### SPACING
        "module/separator" = {
          type = "custom/text";
          content = "|";
          content-padding = 1;
          content-foreground = colors.bg-lighter;
        };

        "module/small-spacer" = {
          type = "custom/text";
          content = " ";
        };

        ### INFO
        # these two could be in one but I want muh separator
        "module/time" = {
          type = "internal/date";
          internal = 5;
          time = "%I:%M:%S %p";
          label = "%time%";
        };
        "module/date" = {
          type = "internal/date";
          internal = 5;
          date = "%d/%m/%y";
          label = "%date%";
        };

        "module/volume" = {
          type = "internal/pulseaudio";
          use-ui-max = false;

          format-volume = "<ramp-volume> <label-volume>";

          label-muted = "${icons.volume-mute} Muted";

          ramp-volume-0 = icons.volume-off;
          ramp-volume-1 = icons.volume-down;
          ramp-volume-2 = icons.volume-up;
        };

        "module/mpd" = {
          type = "internal/mpd";
          host = config.services.mpd.network.listenAddress;
          port = config.services.mpd.network.port;

          format-online = "${icons.music} <label-song> <label-time>";
          format-offline = "${icons.music} mpd is offline";

          label-song = "%artist% - %title%";
          label-time = "[%elapsed%/%total%]";
        };

        "module/cpu" = {
          type = "internal/cpu";
          format-prefix = "${icons.microchip} ";
        };

        "module/memory" = {
          type = "internal/memory";
          format = "${icons.memory} <label>";
          label = "%gb_used%/%gb_total%";
        };

        # error: A definition for option `home-manager.users.ckie.services.polybar.config."module/backlight".card' is not of type `string or boolean or signed integer or list of string'. Definition values:
        #        - In `/home/ckie/git/nixfiles/modules/home/polybar': null
        "module/backlight" = mkIf (cfg.backlight != null) {
          type = "internal/backlight";
          card = cfg.backlight;
          enable-scroll = true;
          format = "${icons.sun} <label>";
        };

        "module/battery" = {
          type = "internal/battery";
          battery = "BAT0";
          adapter = "AC";

          time-format = "%H:%M";

          label-charging = "%percentage%% (%time%)";
          label-discharging = "%percentage%% (%time%)";
          label-full = "%percentage%%";

          format-charging = "<animation-charging> <label-charging>";
          format-discharging = "<animation-discharging> <label-discharging>";
          format-full = "${icons.battery-full} <label-full>";

          # in ms
          animation-charging-framerate = 750;
          animation-discharging-framerate = 500;

          # this isn't in `icons` as I am lazy and I'm not going to use this anywhere else.

          animation-charging-0 = "";
          animation-charging-1 = "";
          animation-charging-2 = "";
          animation-charging-3 = "";
          animation-charging-4 = "";

          animation-discharging-0 = "";
          animation-discharging-1 = "";
          animation-discharging-2 = "";
          animation-discharging-3 = "";
          animation-discharging-4 = "";
        };

        "module/ws" = {
          type = "internal/i3";

          pin-workspaces = true; # each monitor has its own workspaces
          enable-scroll = true;
          wrapping-scroll = false;

          label-visible-background = colors.bg-light;
          label-focused-background = colors.primary;
          label-urgent-background = colors.alert;
          label-urgent-foreground = colors.black;

          label-focused = "%name%";
          label-unfocused = "%name%";
          label-visible = "%name%";
          label-urgent = "%name%";

          label-mode-padding = 1;
          label-focused-padding = 1;
          label-unfocused-padding = 1;
          label-urgent-padding = 1;
          label-visible-padding = 1;

        };

        "module/keyboard" = {
          type = "internal/xkeyboard";
          format = "${icons.globe} <label-layout>";
        };

        # A progress indicator for the polyprog script
        "module/polyprog" = {
          type = "custom/ipc";
          hook-0 =
            "${pkgs.coreutils}/bin/cat $XDG_RUNTIME_DIR/polybar_polyprog_msg";
        };

        "module/shower" = {
          type = "custom/script";
          format-prefix = "${icons.shower} ";
          exec = "${mkRequiresScript ./shower-longpoll}";
          tail = true; # we run forever instead of getting executed many times
        };

        "module/prom" = {
          type = "custom/script";
          exec = "${mkRequiresScript ./prom}";
        };
      };
    };
  };
}
