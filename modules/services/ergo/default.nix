{ lib, config, pkgs, ... }:
with lib;
let cfg = config.cookie.services.ergo;

in {
  options.cookie.services.ergo = {
    enable = mkEnableOption "Ergo IRC service";

    fqdn = mkOption {
      type = types.str;
      default = "puppycat.house";
      description = "Full host to share";
    };
  };

  config = mkIf cfg.enable {
    assertions = [{
      assertion = cfg.enable -> !config.cookie.services.znc.enable;
      message = "blabl lbla no ergo + znc. xor.";
    }];

    networking.firewall.allowedTCPPorts = [ 6697 ];

    systemd.services.ergochat.serviceConfig = {
      LoadCredential = [
        "fullchain.pem:/var/lib/acme/${cfg.fqdn}/fullchain.pem"
        "key.pem:/var/lib/acme/${cfg.fqdn}/key.pem"
      ];
    };

    services.ergochat = {
      enable = true;
      settings = {
        accounts.multiclient = {
          enable = true;
          allowed-by-default = true;
        };

        logging = [{
          level = "debug";
          type = "* -userinput -useroutput";
          method = "stderr";
        }];

        server = {
          listeners = {
            ":6667" = {
              sts-only = true;
            };

            ":6697" = {
              tls = {
                # $CREDENTIALS_DIRECTORY, but instead using the non-public API cause I don't
                # think we have variable subst in here (haven't tried)
                cert = "/run/credentials/ergochat.service/fullchain.pem";
                key = "/run/credentials/ergochat.service/key.pem";
              };

              min-tls-version = 1.2;
            };
          };

          sts = {
            enabled = true;
            # how long clients should be forced to use TLS for.
            duration = "1mo2d5m";
          };

          name = cfg.fqdn;
          motd = pkgs.writeText "ergo.motd" "TODO: Welcome back!";

          opers = {
            # default operator named 'admin'; log in with /OPER admin <password>
            admin = {
              # which capabilities this oper has access to
              class = "server-admin";

              # operators can be authenticated either by password (with the /OPER command),
              # or by certificate fingerprint, or both. if a password hash is set, then a
              # password is required to oper up (e.g., /OPER ckie mypassword). to generate
              # the hash, use `ergo genpasswd`.
              password =
                "$2a$04$Pop3fQQs.ETdNzUloRGw7ead6Toud0fSxPctZi7Ma/lPsXYThM87O";
            };
          };
        };

      };
    };
  };
}
