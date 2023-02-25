{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.cookie.services.matrix;
  janitorHost = "janitor.${cfg.serviceHost}";
in {
  config = mkIf cfg.enable {
    # this is Bad. diskspace-janitor should really support having its own user or something,
    # and the NixOS module should be able to make everything and just do this at service start.
    cookie.secrets.matrix-admin-token = {
      source = "./secrets/matrix-admin-token";
      permissions = "0400";
      wantedBy = "matrix-synapse-diskspace-janitor.service";
    };

    # Rather annoyingly, it seems to want its own origin for whatever reason.
    # TODO: Ask forest about whether this requirement could be lifted
    services.nginx.virtualHosts.${janitorHost} = {
      locations."/".proxyPass = "http://[::1]:6712";
      extraConfig = ''
        access_log /var/log/nginx/matrix-janitor.access.log;
      '';
    };
    cookie.services.prometheus.nginx-vhosts = [ "matrix-janitor" ];

    services.matrix-synapse-diskspace-janitor = {
      enable = true;
      adminTokenFile = config.cookie.secrets.matrix-admin-token.dest;
      settings = {
        FrontendPort = 6712;
        FrontendDomain = janitorHost;
        MatrixServerPublicDomain = cfg.host;
        MatrixURL = "http://[::1]:8008";
        DatabaseType = "postgres";
        DatabaseConnectionString = "host=127.0.0.1 dbname=synapse user=synapse sslmode=disable";
        # practically no-op these out
        MediaFolder = "/dev";
        PostgresFolder = "/dev";

        AdminMatrixRoomId = "!TQhDLYjmzRpYNQmbue:ckie.dev";
      };
    };
  };
}
