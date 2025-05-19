{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.sosse;

in with lib; {
  options.cookie.services.sosse = {
    enable = mkEnableOption "SOSSE web archiver";
    host = mkOption {
      type = types.str;
      description = "host for the web interface";
      default = "sosse.tailnet.ckie.dev";
    };
  };

  config = mkIf cfg.enable {
    cookie.services.nginx.enable = true;
    cookie.services.prometheus.nginx-vhosts = [ "sosse" ];
    services.nginx.virtualHosts.${cfg.host} = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:18438";
        extraConfig = ''
          access_log /var/log/nginx/sosse.access.log;
        '';
      };
    };

    cookie.services.postgres = {
      enable = true;
      comb.sosse = {
        ensureDBOwnership = true;
        networkTrusted = "172.17.0.0/24";
      };
    };

    services.postgresql.settings.listen_addresses =
      mkForce "localhost,172.17.0.1";
    networking.firewall.interfaces.docker0.allowedTCPPorts = [ 5432 ];

    virtualisation.oci-containers.containers.sosse = {
      image =
        # v2025-05-08, https://hub.docker.com/r/biolds/sosse/tags
        # biolds/sosse:pip-compose
        "docker.io/biolds/sosse@sha256:2c57ee4269d33e0d70df82d2346cedd4579240cbb7ab882ef4cd1b71852d7eaa";
      ports = [ "127.0.0.1:18438:80" ];
      autoStart = true;
      volumes = [
        "/mnt/chonk/sosse/data:/var/lib/sosse"
        "/mnt/chonk/sosse/conf:/etc/sosse"
        "/mnt/chonk/sosse/log:/var/log/sosse"
      ];
      environment = {
        SOSSE_DB_NAME = "sosse";
        SOSSE_DB_USER = "sosse";
        SOSSE_DB_HOST = "host.docker.internal";
      };
      extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
    };
  };
}
