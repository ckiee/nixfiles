{ nodes, lib, config, pkgs, ... }:

let cfg = config.cookie.tailnet-certs;
in with lib;
with builtins; {
  config = mkIf cfg.enableServer (mkMerge [
    {
      cookie.bindfs.tailnet-certs = {
        source = "/var/lib/acme/${cfg.host}";
        dest = "/var/lib/tailnet-certs";
        overlay = false;
        args = "-u nginx -g nginx -p 0400,u+D";
      };

      services.nginx.virtualHosts.${cfg.serveHost} = {
        forceSSL = true;
        useACMEHost = cfg.host;
        locations."/" = {
          root = "/var/lib/tailnet-certs";
          extraConfig = ''
            allow 100.64.0.0/10;
            deny all;
            auth_basic "tailnet-certs";
            auth_basic_user_file ${../../secrets/tailnet-certs-htpasswd};
          '';
        };
      };
    }
    {
      systemd.services = rec {
        nginx = rec {
          wantedBy = [ "coredns.service" ];
          after = wantedBy;
        };
        nginx-config-reload = nginx;
      };

      cookie.services.prometheus.nginx-vhosts = [ "tailnet-certs-proxy" ];
      services.nginx.virtualHosts = mkMerge (map (vhost: ({
        ${vhost} = {
          forceSSL = true;
          useACMEHost = cfg.host;
          locations."/".proxyPass = "https://${vhost}";
          extraConfig = ''
            access_log /var/log/nginx/tailnet-certs-proxy.access.log;
          '';
        };
      })) (flatten
        (mapAttrsToList (_: h: h.config.cookie.tailnet-certs.client.forward)
          nodes)));
    }
  ]);
}
