{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.hedgedoc;

in with lib; {
  options.cookie.services.hedgedoc = {
    enable = mkEnableOption "HedgeDoc";
    host = mkOption {
      type = types.str;
      description = "host for the web interface";
      default = "pad.pupc.at";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.hedgedoc.after = [ "postgresql.service" ];
    services.hedgedoc = {
      enable = true;
      settings = {
        db = {
          dialect = "postgres";
          user = "hedgedoc";
          host = "/run/postgresql";
          database = "hedgedoc";
        };
        domain = cfg.host;
        allowOrigin = [ cfg.host ];
        protocolUseSSL = true;
        port = 29581;
        allowAnonymous = false;
      };
    };

    cookie.services.postgres = {
      enable = true;
      comb.hedgedoc = { ensureDBOwnership = true; };
    };

    cookie.services.nginx.enable = true;
    cookie.services.prometheus.nginx-vhosts = [ "hedgedoc" ];
    services.nginx.virtualHosts.${cfg.host} = {
      locations."/" = {
        proxyPass = "http://localhost:29581";
        extraConfig = ''
          access_log /var/log/nginx/hedgedoc.access.log;
        '';
      };
    };
  };
}
