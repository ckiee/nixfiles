{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.vaultwarden;

in with lib; {
  options.cookie.services.vaultwarden = {
    enable = mkEnableOption "vaultwarden service";
    host = mkOption {
      type = types.str;
      description = "API host";
      default = "vw.ckie.dev";
    };
  };

  config = mkIf cfg.enable {
    cookie.secrets.vaultwarden = {
      source = "./secrets/vaultwarden.env";
      owner = "root"; # systemd loads into service as root.
      permissions = "0400";
      wantedBy = "vaultwarden.service";
    };

    services.vaultwarden = {
      enable = true;
      dbBackend = "postgresql";
      environmentFile = config.cookie.secrets.vaultwarden.dest;

      config = {
        # env vars, converted to CAPITAL_SNAKE
        rocketAddress = "127.0.0.1";
        rocketPort = 8852;

        databaseUrl = "postgresql://vaultwarden@/vaultwarden";
        domain = "https://${cfg.host}";
        signupsAllowed = false;
        pushEnabled = true;

        # FIXME: smtp. flowe doesnt have the mailserver migrated 2 it yet. needs creds.
      };
    };

    #FIXME:restic https://github.com/dani-garcia/vaultwarden/wiki/Backing-up-your-vault

    cookie.services.postgres = {
      enable = true;
      comb.vaultwarden = { };
    };

    services.nginx = {
      virtualHosts."${cfg.host}" = {
        locations."/" = { proxyPass = "http://127.0.0.1:8852"; };
        extraConfig = ''
          access_log /var/log/nginx/vaultwarden.access.log;
        '';
      };
    };
    #
    cookie.services.prometheus.nginx-vhosts = [ "vaultwarden" ];

    # make sure we don't crash because postgres isn't ready
    systemd.services.vaultwarden.after = [ "postgresql.service" ];

  };
}
