{ lib, config, pkgs, ... }:

# From https://github.com/Xe/nixos-configs/
let cfg = config.cookie.services.prometheus;

in with lib; {
  options.cookie.services.prometheus = {
    enable = mkEnableOption "Enables the Prometheus monitoring service";
    nginx-vhosts = mkOption rec {
      type = types.listOf types.str;
      description = "List of nginx virtual host names";
    };
  };

  config = mkIf cfg.enable {
    services.nginx.statusPage = true; # needed for nginxlog
    services.grafana = {
      enable = true;
      port = 8571;
      domain = "devel.grafana.ronthecookie.me";
    };
    services.nginx = {
      virtualHosts."devel.grafana.ronthecookie.me" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.grafana.port}";
        };
        extraConfig = ''
          access_log /var/log/nginx/grafana.access.log;
        '';
      };
    };
    cookie.services.prometheus.nginx-vhosts = [ "grafana" ];

    services.prometheus = {
      enable = true;
      globalConfig.scrape_interval = "5s";
      scrapeConfigs = let
        listenMap = host: ports:
          (imap0 (i: v: ("${host}:${toString v}")) ports);
      in [
        {
          job_name = "nginx";
          static_configs = [{ targets = listenMap "127.0.0.1" [ 9113 9117 ]; }];
        }
        {
          job_name = config.networking.hostName;

          static_configs = [{ targets = listenMap "127.0.0.1" [ 9100 ]; }];
        }
      ];
      exporters = let listenAddress = "127.0.0.1";
      in {
        node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
          inherit listenAddress;
        };
        nginx = {
          enable = true;
          inherit listenAddress;
        };
        nginxlog = {
          enable = true;
          inherit listenAddress;
          settings = {
            namespaces = let
              format = ''
                $remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent"'';
              mkApp = name: {
                metrics_override.prefix = "nginx";
                inherit name format;
                source.files = [ "/var/log/nginx/${name}.access.log" ];
                namespace_label = "vhost";
              };
            in [{
              name = "filelogger";
              inherit format;
              source.files = [ "/var/log/nginx/access.log" ];
            }] ++ imap0 (i: value: mkApp value) cfg.nginx-vhosts;
          };
          group = "nginx";
          user = "nginx";
        };
      };
    };
  };
}
