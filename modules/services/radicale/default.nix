{ lib, config, ... }:

let cfg = config.cookie.services.radicale;

in with lib; {
  options.cookie.services.radicale = {
    enable = mkEnableOption "radicale CalDAV service";
    hostname = mkOption {
      type = types.str;
      default = "dav.ckie.dev";
    };
    port = mkOption {
      type = types.port;
      default = 5232;
    };
  };

  config = mkIf cfg.enable {
    cookie.services.nginx.enable = true;

    services.nginx.virtualHosts.${cfg.hostname} = {
      locations."/".proxyPass = "http://localhost:${toString cfg.port}";
      extraConfig = ''
        proxy_set_header X-Script-Name /;
        proxy_pass_header Authorization;
      '';
    };

    cookie.secrets.radicale-htpasswd = {
      source = "./secrets/radicale-htpasswd";
      owner = "radicale";
      group = "radicale";
      permissions = "0400";
      wantedBy = "radicale.service";
      dest = "/var/lib/radicale/htpasswd";
    };

    cookie.restic.paths = [ "/var/lib/radicale" ];

    services.radicale = {
      enable = true;
      settings = {
        server.hosts = [ "localhost:${toString cfg.port}" ];
        auth = {
          type = "htpasswd";
          htpasswd_filename = config.cookie.secrets.radicale-htpasswd.dest;
          htpasswd_encryption = "bcrypt";
        };
        storage.filesystem_folder = "/var/lib/radicale/collections";
      };
    };
  };
}
