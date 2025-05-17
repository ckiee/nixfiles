{ lib, config, pkgs, nixosConfig, util, ... }:

let
  cfg = config.cookie.waybar;
  soundCfg = nixosConfig.cookie.sound;
  inherit (util) mkRequiresScript;

  colors = {
    primary = "#ed60ba";
    alert = "#ffe261";
    bg-lighter = "#5f5f5f";
    bg-light = "#27212e";
    bg-dark = "#171717";
    black = "#000000";
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
    bluetooth = "";
    moon = "";
    broom = "";
    plug = "";
  };
in with lib; {
  options.cookie.waybar = {
    enable = mkEnableOption "waybar";

    laptop = mkEnableOption "Enables laptop-specific reporting";
  };

  config = mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      package = pkgs.waybar.overrideAttrs (prev: {
        patches = (prev.patches or [ ])
          ++ [ ./0001-feat-mpd-add-titleOrFilename.patch ];
      });

      systemd.enable = true;
      systemd.target = "sway-session.target";

      style = ./waybar.css;

      settings = [{
        position = "bottom";
        height = 24; # managed to get to 20px on polybar..!
        # output = [ "!…" ];
        modules-left = [ "sway/workspaces" "sway/mode" ];
        # modules-center = [ "sway/window" ];
        modules-right = [ "mpd" ]
          ++ optionals soundCfg.pipewire.enable [ "wireplumber" ] ++ [
            "privacy"
            "memory"
            "cpu"
            "sway/language"
            "idle_inhibitor"
          ]
          # ++ optionals (cfg.backlight != null) [ "backlight" ]
          ++ optionals cfg.laptop [ "backlight" "battery" ]
          ++ [ "custom/sunset" "clock" "tray" ];

        "sway/workspaces" = { all-outputs = true; };
        "sway/mode" = { tooltip = false; };
        "sway/window" = { max-length = 120; };

        "idle_inhibitor" = {
          format = "${icons.broom}";
          timeout = 120; # minutes
        };

        "mpd" = {
          format =
            "${icons.music} {artist} - {titleOrFilename} [{elapsedTime:%M:%S}/{totalTime:%M:%S}]";
          format-disconnected = "";
          format-stopped = "";
        };

        "wireplumber" = {
          format = "{icon} {volume}%";
          format-muted = "${icons.volume-mute} Muted";

          format-icons = [ icons.volume-down icons.volume-up ];
        };

        "memory" = {
          interval = 1;
          format = "${icons.memory} {used:0.1f} GiB/{total:0.1f} GiB";
        };

        "cpu" = {
          interval = 1;
          format = "${icons.microchip} {usage}%";
        };

        "sway/language" = {
          format = "${icons.globe} {short}";
          on-click = "swaymsg input type:keyboard xkb_switch_layout next";
        };

        "custom/sunset" = {
          format = "${icons.moon} {text}";
          exec = "${mkRequiresScript ./sunset}";
          return-type = "json";
        };

        "clock" = {
          interval = 1;
          format = "{:%d/%m/%y %r}";
        };

        "backlight" = { format = "${icons.sun} {percent}%"; };

        "battery" = {
          format = "{icon} {capacity}% ({time})";
          format-full = "{icon} {capacity}%";
          format-charging = "${icons.plug} {capacity}% ({time})";

          format-time = "{H}:{m}";
          states = { critical = 15; };
          full-at = 95;
          format-icons = [
            ""
            ""
            ""
            ""
            ""

          ];
        };
      }
      # {
      #   position = "bottom";
      #   output = [ "!DP-1" ];
      #   modules-left = [ "sway/mode" ];
      #   modules-center = [ "clock" ];
      #   modules = { "sway/mode" = { tooltip = true; }; };
      # }
        ];
    };
  };
}
