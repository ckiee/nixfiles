{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.grafana;

in with lib; {
  options.cookie.services.grafana = {
    enable = mkEnableOption "Enables grafana service";
    host = mkOption {
      type = types.str;
      default = "grafana.localhost";
      description = "the host. wow.";
      example = "grafana.ckie.dev";
    };
  };

  config = mkIf cfg.enable {
    cookie.services.nginx.enable = true;

    services.grafana = {
      enable = true;
      settings = {
        # actual permissions are determined be denied by grafana's state
        # (it's per dashboard, and hidden in the settings UI for each one.)
        "auth.anonymous" = {
          enable = true;
          org_role = "Viewer";
        };

        server = {
          domain = cfg.host;
          http_port = 8571;
        };
      };
    };

    cookie.restic.paths = [ config.services.grafana.database.path ];

    services.nginx = {
      virtualHosts.${cfg.host} = {
        locations."/" = {
          proxyPass =
            "http://127.0.0.1:${toString config.services.grafana.port}";
        };
        extraConfig = ''
          access_log /var/log/nginx/grafana.access.log;
        '';
      };
    };
    cookie.services.prometheus.nginx-vhosts = [ "grafana" ];
  };
}
