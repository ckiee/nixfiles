{ sources, lib, config, pkgs, ... }:

with lib;

let
  cfg = config.cookie.mpd;
  sound = config.cookie.sound;
  home = config.cookie.user.home;
  port = "14725";
in {
  options.cookie.mpd = {
    enable = mkEnableOption "Enables the music player daemon";
    enableHttp = mkEnableOption
      "Exposes a HTTP server streaming the currently played track";
    host = mkOption {
      type = types.str;
      description = "Host for web interface";
      default = "listenwithme.tailnet.ckie.dev";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home-manager.users.ckie = { config, ... }: {
        services.mpd = {
          enable = true;
          dataDir = "${home}/Sync/mpd";
          dbFile = "${home}/Sync/.mpd-db";
          musicDirectory = "${home}/Music/flat";
          extraConfig =
            # PipeWire can emulate PulseAudio and it might work better sometimes
            ''
              ${optionalString (sound.pulse.enable || sound.pipewire.enable) ''
                audio_output {
                  type "pulse"
                  name "pulseaudio"
                }
              ''}
              # zeroconf is broken
              zeroconf_enabled "no"
              ${optionalString cfg.enableHttp ''
                # https://wiki.archlinux.org/title/Music_Player_Daemon/Tips_and_tricks#HTTP_streaming
                audio_output {
                  type "httpd"
                  name "cookie mpd! (:"
                  encoder "opus"
                  port "${port}"
                  bitrate "128000"
                  format "48000:16:1"
                  # prevent MPD from disconnecting all listeners when playback is stopped.
                  always_on "yes"
                  tags "yes"
                }
              ''}
            '';
        };

        systemd.user.services.mpd.Service.ExecStartPost =
          "${pkgs.mpc_cli}/bin/mpc crossfade 1"; # set crossfade to 1sec
        services.mpdris2.enable = true;

        home.packages = with pkgs; [
          # GUI Frontends
          cantata
          # Utilities
          mpc_cli
          spotdl
          puddletag # ...for when the metadata gets messed up
        ];

      };

    }

    (mkIf cfg.enableHttp {
      ### nginx reverse proxy
      cookie.services.nginx.enable = true;
      cookie.services.prometheus.nginx-vhosts = [ "mpd" ];
      services.nginx.virtualHosts.${cfg.host} = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${port}";
          extraConfig = ''
            access_log /var/log/nginx/mpd.access.log;
          '';
        };
      };
      ### get tls cert
      cookie.tailnet-certs.client = rec {
        enable = true;
        hosts = singleton cfg.host;
        forward = hosts;
      };
    })

  ]);
}