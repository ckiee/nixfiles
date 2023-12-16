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

        smtpHost = "mx.ckie.dev";
        smtpFrom = "vaultwarden@ckie.dev";
        useSendmail = true;
      };
    };

    users.users.vaultwarden.extraGroups = [ "postdrop" ];
    systemd.services.vaultwarden = {
      path = [ "/run/wrappers" ]; # for sendmail. definitely needed.
      # XXX: unsure if these two are needed:
      serviceConfig = {
        ReadWriteDirectories = [ "/var/lib/postfix/queue/maildrop" ];
        RestrictAddressFamilies =
          [ "AF_UNIX" "AF_INET" "AF_INET6" "AF_LOCAL" "AF_NETLINK" ];
      };
    };

    cookie.restic.paths =
      [ "/var/lib/bitwarden_rs" ]; # check this before bumping stateVersion!

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
