{ config, lib, pkgs, nixosConfig, ... }:

let
  inherit (lib)
    optionals mkIf mkEnableOption mkOption types concatStrings optional;

  colors = {
    primary = "#ed60ba";
    alert = "#ffe261";
    bg-lighter = "#5f5f5f";
    bg-light = "#27212e";
    bg-dark = "#1b1720";
    black = "#000000";
  };
  base = {
    width = "100%";
    height = 20;
    bottom = true;
    radius = 0;

    font-0 = "Hack:size=9";
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
  };
  cfg = config.cookie.polybar;
  desktopCfg = nixosConfig.cookie.desktop;
  pkg = config.services.polybar.package;
in {

  options.cookie.polybar = {
    enable = mkEnableOption "Enables Polybar";
    laptop = mkEnableOption "Enables laptop-specific reporting";
  };

  config = mkIf cfg.enable {
    xsession.windowManager.i3.config.startup = [{
      command = pkgs.writeShellScript "polybar-starter" ''
        while true; do polybar main; sleep 0.1; done
        ${mkIf (desktopCfg.secondaryMonitor != null)
        "(while true; do polybar main; sleep 0.1; done) &"}
      '';
      notification = false;
    }];

    services.polybar = {
      enable = true;
      package = pkgs.polybar.override {
        i3GapsSupport = true;
        pulseSupport = true;
        mpdSupport = true;
      };

      script =
        ""; # we aren't really using the service as it runs before i3 and we need i3 ipc

      config = {
        "bar/main" = base // {
          monitor =
            mkIf (desktopCfg.primaryMonitor != null) desktopCfg.primaryMonitor;

          modules-left = "ws";
          modules-right = [
            "polyprog"
            "mpd"
            "separator"
            "volume"
            "separator"
            "memory"
            "small-spacer"
            "cpu"
            "separator"
            "keyboard"
          ] ++ optionals cfg.laptop [
            "separator"
            "backlight"
            "separator"
            "battery"
          ] ++ [ "separator" "date" "small-spacer" "time" "separator" ];

          tray-position = "right";
          tray-padding = 0;

          # For module/polyprog
          enable-ipc = true;
        };

        "bar/side" = mkIf (desktopCfg.secondaryMonitor != null) (base // {
          monitor = desktopCfg.secondaryMonitor;

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

        "module/backlight" = {
          type = "internal/backlight";
          card = "intel_backlight";
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

        # A progress indicato for the polyprog script
        "module/polyprog" = {
          type = "custom/ipc";
          hook-0 = "cat $XDG_RUNTIME_DIR/polybar_polyprog_msg";
        };
      };
    };
  };
}
