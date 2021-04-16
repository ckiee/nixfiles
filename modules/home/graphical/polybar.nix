{ config, lib, pkgs, ... }:

let
  inherit (lib) optionals mkIf mkEnableOption mkOption types concatStrings;

  colors = {
    primary = "#ed60ba";
    alert = "#ffe261";
    bg-lighter = "#5f5f5f";
    bg-light = "#27212e";
    bg-dark = "#1b1720";
  };
  base = {
    width = "100%";
    height = 20;
    bottom = true;
    radius = 0;

    font-0 = "Hack:size=9";
    font-1 = "Font Awesome 5 Free:style=Solid:size=9";
    font-2 = "Noto Color Emoji:size=9";

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
  };
  cfg = config.ron.polybar;
in {

  options.ron.polybar = {
    enable = mkEnableOption "Enables Polybar";
    laptop = mkEnableOption "Enables laptop-specific reporting";
    primaryMonitor = mkOption {
      type = types.str;
      example = "eDP-1";
      description = "primary output";
    };
    secondaryMonitor = mkOption {
      type = types.nullOr types.str;
      example = "eDP-1";
      description = "secondary output";
      default = null;
    };
  };

  config = mkIf cfg.enable {
    services.polybar = {
      enable = true;
      package = pkgs.polybar.override {
        i3GapsSupport = true;
        pulseSupport = true;
      };

      script = ''
        polybar main &
        ${if (cfg.secondaryMonitor != null) then "polybar side &" else ""}
      '';

      config = {
        "bar/main" = base // {
          monitor = cfg.primaryMonitor;

          modules-left = "ws";
          modules-right = [ "memory" "small-spacer" "cpu" "separator" "volume" ]
            ++ optionals cfg.laptop [
              "separator"
              "backlight"
              "separator"
              "battery"
            ] ++ [ "separator" "date" "small-spacer" "time" "separator" ];

          tray-position = "right";
          tray-padding = 0;
        };

        "bar/side" = mkIf (cfg.secondaryMonitor != null) (base // {
          monitor = cfg.secondaryMonitor;

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
          use-ui-max = true;

          format-volume = "<ramp-volume> <label-volume>";

          label-muted = "${icons.volume-mute} ";

          ramp-volume-0 = icons.volume-off;
          ramp-volume-1 = icons.volume-down;
          ramp-volume-2 = icons.volume-up;
        };

        "module/cpu" = {
          type = "internal/cpu";
          format-prefix = "${icons.microchip} ";
        };

        "module/memory" = {
          type = "internal/memory";
          format-prefix = "${icons.memory} ";
        };

        "module/backlight" = {
          type = "internal/backlight";
          card = "intel_backlight";
          enable-scroll = true;
        };

        "module/battery" = {
          type = "internal/battery";
          battery = "BAT0";
          adapter = "AC";
        };

        "module/ws" = {
          type = "internal/i3";

          pin-workspaces = true; # each monitor has its own workspaces
          enable-scroll = true;
          wrapping-scroll = false;

          label-visible-background = colors.bg-light;
          label-focused-background = colors.primary;
          label-urgent-background = colors.alert;

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
      };
    };
  };
}
