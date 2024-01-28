{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.actual;

in with lib; {
  options.cookie.services.actual = {
    enable = mkEnableOption "actual service";
    serveHost = mkOption {
      type = types.str;
      default = "actual.ckie.dev";
      description = "Host to serve on";
    };
  };

  imports = [ (import ../../../pkgs {}).actual-server.passthru.nixosModule ];

  config = mkIf cfg.enable {
    services.actual-server = {
      enable = true;
      port = 5006;
    };

    cookie.services.nginx.enable = true;
    cookie.services.prometheus.nginx-vhosts = [ "actual" ];
    services.nginx.virtualHosts.${cfg.serveHost} = {
      locations."/" = { proxyPass = "http://localhost:5006"; };

      extraConfig = ''
        access_log /var/log/nginx/actual.access.log;
      '';
    };

    cookie.restic.paths = [ config.services.actual-server.stateDir ];

    # No extra tailnet-certs setup as its going on flowe.

  };
}
