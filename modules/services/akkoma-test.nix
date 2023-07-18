{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.akkoma-test;

in with lib; {
  options.cookie.services.akkoma-test = {
    enable = mkEnableOption "Enables an akkoma instance for local testing";
    host = mkOption {
      type = types.str;
      default = "akkoma-test.tailnet.ckie.dev";
    };
  };

  config = mkIf cfg.enable {
    cookie.services = {
      nginx.enable = true;
      postgres.enable = true;
    };

    services.akkoma = {
      enable = true;
      config = {
        ":pleroma" = {
          ":instance" = {
            name = "ckie akkoma testing";
            description = "mrew";
            email = "admin@example.com";
            registration_open = false;
          };

          "Pleroma.Web.Endpoint" = { url.host = cfg.host; };
        };
      };
      nginx = {
        # enableACME = true;
        forceSSL = true;
        sslCertificate = "/var/lib/tailnet-certs/fullchain.pem";
        sslCertificateKey = "/var/lib/tailnet-certs/key.pem";
        sslTrustedCertificate = "/var/lib/tailnet-certs/chain.pem";
      };
    };

    cookie.tailnet-certs.client = rec {
      enable = true;
      hosts = singleton cfg.host;
      forward = hosts;
    };

    # TODO?
    # cookie.restic.paths = [ config.services.akkoma-test.??? ];

  };
}
