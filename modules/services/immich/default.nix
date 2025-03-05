{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.immich;

in with lib; {
  options.cookie.services.immich = {
    enable = mkEnableOption "immich photogallery";
    host = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "host for the web interface";
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.settings = {
      immich = {
        "${config.services.immich.mediaLocation}" = rec {
          d = {
            user = "ckie";
            group = "immich";
            mode = "0770";
          };
          e = mkForce d;
        };
      };
    };
    cookie.restic.paths = [ config.services.immich.mediaLocation ];

    services.immich = {
      enable = true;
      mediaLocation = "/mnt/chonk/immich";
      host = "localhost";
      port = 2283;
      settings = { server.externalDomain = "https://${cfg.host}"; };
    };

    cookie.services.nginx.enable = true;
    cookie.services.prometheus.nginx-vhosts = [ "immich" ];
    services.nginx.virtualHosts.${cfg.host} = {
      locations."/" = {
        proxyPass = "http://localhost:2283";
        proxyWebsockets = true;
        extraConfig = ''
          access_log /var/log/nginx/immich.access.log;
          proxy_send_timeout 100;
          client_max_body_size 1G;
        '';
      };
    };
  };
}
