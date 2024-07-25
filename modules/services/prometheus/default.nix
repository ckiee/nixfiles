{ lib, config, pkgs, nodes, ... }:

with lib;

let
  cfg = config.cookie.services.prometheus;
  # this little boilerplate is here because I used to rewrite bokkusu's address
  # in order to keep the old prom data, which didn't work
  listenAddress = config.cookie.wireguard.ipv4;
in {
  options.cookie.services.prometheus = {
    enableServer = mkEnableOption "Prometheus monitoring service";
    enableClient = mkEnableOption "relevant Prometheus exporters"
      // {
        default = true;
      };

    # TODO: make this be able to work with non-native-to-NixOS exporters
    exporters = mkOption {
      type = types.listOf types.str;
      default = [ ];
      internal = true;
      description = "Enabled exporters for this machine";
    };

    # TODO: get rid of this junk
    nginx-vhosts = mkOption rec {
      type = types.listOf types.str;
      default = [ ];
      description = "List of nginx virtual host names";
    };
  };

  imports = [
    ./alerting.nix
    ./blackbox.nix
    ./smart
  ];

  config = mkMerge [
    # {
    #   cookie.services.prometheus.enableClient =
    #     mkDefault ((length cfg.exporters) > 0);
    # }
    # infinite recursion ^^

    (mkIf cfg.enableServer {
      networking.firewall.interfaces.tailscale0.allowedTCPPorts =
        [ 9090 9093 ]; # prom, alert-manager

      services.prometheus = {
        enable = true;
        # I want to see longer trends in hardware reliability, since that's a problem now unfortunately..
        retentionTime = "60d";
        globalConfig.scrape_interval = "5s";
        rules = [ (builtins.readFile ./node_rules.yaml) ];

        alertmanagers = [{
          scheme = "http";
          path_prefix = "/";
          static_configs = [{ targets = [ "127.0.0.1:9093" ]; }];
          # See ./alerting.nix
        }];

        scrapeConfigs = map (k:
          # this assumes we're using the defaults, so it's the same across all hosts,
          # which is probably wrong, but okay for now.
          #
          # see comment on cfg.exporters mkOpt def too
          let port = config.services.prometheus.exporters.${k}.port;
          in {
            job_name = k;
            static_configs = [{
              targets = map (host: "${host}:${toString port}") (mapAttrsToList
                (_: host: "${host.config.networking.hostName}.cknet")
                (filterAttrs (_: host:
                  let
                    hcfg = host.config.cookie.services.prometheus;
                    includesThisExporter =
                      length (intersectLists [ k ] hcfg.exporters) == 1;
                  in hcfg.enableClient && includesThisExporter) nodes));
            }];
          }) cfg.exporters;

      };
    })

    (mkIf (cfg.enableClient) (mkMerge [
      # expose the exporters' ports to cknet (internal wireguard)
      {
        networking.firewall.interfaces.cknet.allowedTCPPorts =
          map (exp: config.services.prometheus.exporters.${exp}.port)
          cfg.exporters;
      }

      # TODO: matrix-appservice-discord, matrix-synapse, prom itself, probably bazillion other things.
      # need to allow non-NixOS-services.prom.exporters.* exporters for those i think
      # also should just iterate through services
      #
      # check TODO in grafana module too

      {
        cookie.services.prometheus.exporters = [ "node" ];
        # https://grahamc.com/blog/nixos-system-version-prometheus
        system.activationScripts.node-exporter-system-version = ''
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
        services.prometheus.exporters.node = {
          enable = true;
          enabledCollectors = [ "systemd" "textfile" ];
          extraFlags = [
            "--collector.textfile.directory=/var/lib/prometheus-node-exporter-text-files"
            "--collector.filesystem.ignored-mount-points=^/(sys|proc|dev|run)($|/)"
          ];
          inherit listenAddress;
        };
      }

      (mkIf config.services.nginx.enable {
        cookie.services.prometheus.exporters = [ "nginxlog" ];
        services.prometheus.exporters.nginxlog = {
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
            }] ++ map mkApp cfg.nginx-vhosts; # XXX
          };
          group = "nginx";
          user = "nginx";
        };
      })

    ]))
  ];
}
