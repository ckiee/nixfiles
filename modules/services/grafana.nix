{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.grafana;

in with lib; {
  options.cookie.services.grafana = {
    enable = mkEnableOption "Enables grafana service";
    host = mkOption {
      type = types.str;
      default = "devel.grafana.ronthecookie.me";
      description = "the host. wow.";
      example = "grafana.ronthecookie.me";
    };
  };

  config = mkIf cfg.enable {
    cookie.services.nginx.enable = true;

    services.grafana = {
      enable = true;
      port = 8571;
      domain = "devel.grafana.ronthecookie.me";
    };

    services.nginx = {
      virtualHosts."devel.grafana.ronthecookie.me" = {
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
