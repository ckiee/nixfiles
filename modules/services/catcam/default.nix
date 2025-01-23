{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.catcam;

in with lib; {
  options.cookie.services.catcam = {
    enable = mkEnableOption "catcam stream";
    host = mkOption {
      type = types.str;
      description = "host for the web interface";
      default = "catcam.tailnet.ckie.dev";
    };
  };

  imports = [ ./catd.nix ];

  config = mkIf cfg.enable {
    systemd.services.catcam = rec {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "catcam-bindfs.service" ];
      wants = after;
      description = "catcam!";
      path = with pkgs; [ ffmpeg ];
      script = ''
        ffmpeg -f v4l2 -i /dev/video0 -c:v libx264 -preset veryfast -tune zerolatency -b:v 4M \
          -f hls -hls_time 2 -hls_list_size 5 -hls_flags delete_segments \
          /var/lib/catcam/index.m3u8
      '';

      serviceConfig = {
        DynamicUser = true;
        User = "catcam";
        Group = "video";
        DeviceAllow = "/dev/video0 rwm";
        Restart = "always";
        StateDirectory = "catcam";
        ReadWritePaths = [ "/var/lib/catcam" ];

        CapabilityBoundingSet = "";
        DevicePolicy = "closed";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateUsers = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        ProtectProc = "invisible";
        ProcSubset = "pid";
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        SystemCallArchitectures = "native";
        UMask = "0077";
      };
    };

    cookie.bindfs.catcam = {
      source = "/var/lib/catcam";
      dest = "/var/www/catcam";
      overlay = false;
      args = "-u nginx -g nginx -p 0440,ug+X -r";
      wantedBy = [ "nginx.service" ];
    };

    cookie.services.nginx.enable = true;
    cookie.services.prometheus.nginx-vhosts = [ "catcam" ];
    services.nginx.virtualHosts.${cfg.host} = {
      locations."/" = {
        root = "/var/www/catcam";
        extraConfig = ''
          access_log /var/log/nginx/catcam.access.log;
        '';
      };
    };
  };
}
