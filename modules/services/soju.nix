{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.soju;

in with lib; {
  options.cookie.services.soju = {
    enable = mkEnableOption "Enables soju, the user-friendly IRC bouncer";
    acmeHost = mkOption {
      type = types.str;
      default = cfg.host;
      description = "the host the certificate is under";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 6698 ];

    users = {
      users.soju = {
        isSystemUser = true;
        group = "soju";
      };
      groups.soju = { };
    };

    systemd.services.soju.serviceConfig = {
      DynamicUser = mkForce false;
      User = "soju";
      Group = "soju";
    };

    cookie.bindfs.soju-acme = {
      source = "/var/lib/acme/ckie.dev";
      dest = "/var/lib/soju/acme";
      overlay = false;
      args = "-u soju -g soju -r -p 0400,u+D";
      wantedBy = [ "soju.service" ];
    };

    cookie.restic.paths = [ "/var/lib/soju/logs" ];

    services.soju = {
      enable = true;
      hostName = config.networking.hostName;
      listen = [ ":6698" ];
      tlsCertificate = "/var/lib/soju/acme/cert.pem";
      tlsCertificateKey = "/var/lib/soju/acme/key.pem";
    };
  };

}
