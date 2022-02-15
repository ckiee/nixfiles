{ lib, config, pkgs, ... }:

# From https://github.com/Xe/nixos-configs/
let
  cfg = config.cookie.services.prometheus;
  node-exporter-system-version = ''
    mkdir -pm 0775 /var/lib/prometheus-node-exporter-text-files
    (
      cd /var/lib/prometheus-node-exporter-text-files
      (
        echo -n "system_version ";
        readlink /nix/var/nix/profiles/system | cut -d- -f2
      ) > system-version.prom.next
      mv system-version.prom.next system-version.prom
    )
  '';
in with lib; {
  options.cookie.services.prometheus = {
    enable = mkEnableOption "Enables the Prometheus monitoring service";
    nginx-vhosts = mkOption rec {
      type = types.listOf types.str;
      default = [ ];
      description = "List of nginx virtual host names";
    };
  };

  config = mkIf cfg.enable {
    # https://grahamc.com/blog/nixos-system-version-prometheus
    system.activationScripts = { inherit node-exporter-system-version; };

    cookie.secrets.prom-alert-webhook = {
      source = "./secrets/prom-alert-webhook.nix";
      runtime = false;
    };

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 9090 ];

    services.prometheus = {
      enable = true;
      globalConfig.scrape_interval = "5s";
      rules = [ (builtins.readFile ./node_rules.yaml) ];
      alertmanager = {
        enable = true;
        configuration = {
          global.slack_api_url = import ../../../secrets/prom-alert-webhook.nix;
          route = {
            group_by = [ "alertname" "cluster" "service" ];
            group_wait = "30s";
            group_interval = "30s";
            repeat_interval = "30s";
            receiver = "null";
          };

          inhibit_rules = [{
            source_matchers = [ ''severity="critical"'' ];
            target_matchers = [ ''severity="warning"'' ];
            # Apply inhibition if the alertname is the same.
            # CAUTION:
            #   If all label names listed in `equal` are missing
            #   from both the source and target alerts,
            #   the inhibition rule will apply!
            equal = [ "alertname" "cluster" "service" ];
          }];

          receivers = [{
            name = "null";
            webhook_configs = [{
              url = "http://192.0.2.1:32212"; # nonexistant, test-net
              send_resolved = true;
            }];
          }];
        };
      };
      alertmanagers = [{
        scheme = "http";
        path_prefix = "/";
        static_configs = [{ targets = [ "127.0.0.1:9093" ]; }];
      }];

      scrapeConfigs = let
        listenMap = host: ports:
          (imap0 (i: v: ("${host}:${toString v}")) ports);
      in [
        {
          job_name = "nginx";
          static_configs = [{ targets = listenMap "127.0.0.1" [ 9117 ]; }];
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
          enabledCollectors = [ "systemd" "textfile" ];
          extraFlags = [
            "--collector.textfile.directory=/var/lib/prometheus-node-exporter-text-files"
          ];
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
