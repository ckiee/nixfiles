{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.headscale;

in with lib; {
  options.cookie.services.headscale = {
    enable = mkEnableOption "Headscale daemon";
    host = mkOption {
      type = types.str;
      description = "host for the web interface";
      default = "headscale.ckie.dev";
    };
    acmeHost = mkOption {
      type = types.str;
      description = "base host for acme";
      default = "ckie.dev";
    };
  };

  config = mkIf cfg.enable {
    cookie.services.postgres = {
      enable = true;
      comb.headscale = { };
    };
    # TODO: restic? is the state worth backing up?
    services.headscale = {
      enable = true;
      serverUrl = "https://${cfg.host}";
      address = "127.0.0.1";
      port = 4329;
      logLevel = "debug";
      settings = {
        logtail.enabled = false;
        db_type = "postgres";
        db_host = "/run/postgresql";
        db_name = "headscale";
        db_user = "headscale";
        db_port = 5432; # not ignored for some reason
      };
    };

    cookie.bindfs.headscale = {
      source = "/var/lib/acme/${cfg.acmeHost}";
      dest = "/var/lib/headscale/acme";
      overlay = false;
      args = "-u headscale -g headscale -p 0400,u+D";
      wantedBy = [ "headscale.service" ];
    };

    cookie.services.nginx.enable = true; # firewall & recommended defaults
    cookie.services.prometheus.nginx-vhosts = [ "headscale" ];
    services.nginx.virtualHosts.${cfg.host} = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:4329";
        extraConfig = ''
          access_log /var/log/nginx/headscale.access.log;
        '';
      };
    };
  };
}
