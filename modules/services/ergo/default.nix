{ lib, config, pkgs, ... }:
with lib;
let cfg = config.cookie.services.ergo;

in {
  options.cookie.services.ergo = {
    enable = mkEnableOption "Ergo IRC service";
  };

  config = mkIf cfg.enable {
    assertions = [{
      assertion = cfg.enable -> !config.cookie.services.znc.enable;
      message = "blabl lbla no ergo + znc. xor.";
    }];

    networking.firewall.allowedTCPPorts = [ 6697 ];

    services.ergochat = {
      enable = true;
      settings.server = {
        name = "puppycat.house";
        motd = pkgs.writeText "ergo.motd" "TODO: Welcome back!";

        accounts.multiclient = {
          enable = true;
          allowed-by-default = true;
        };

        logging.level = "debug";

        server = {
          listeners = {
            ":6697" = {
              sts-only = true;

              tls = {
                cert = "fullchain.pem";
                key = "key.pem";
              };
            };
          };
          sts = {
            enabled = true;
            # how long clients should be forced to use TLS for.
            duration = "1mo2d5m";
          };
        };

        opers = rec {
          # default operator named 'admin'; log in with /OPER admin <password>
          ckie = {
            # which capabilities this oper has access to
            class = "server-admin";

            # operators can be authenticated either by password (with the /OPER command),
            # or by certificate fingerprint, or both. if a password hash is set, then a
            # password is required to oper up (e.g., /OPER ckie mypassword). to generate
            # the hash, use `ergo genpasswd`.
            password =
              "$2a$04$ltQIKNwu8aR1jImueQTkUuEA4RBRD.zSP3xh5e6gbvvggV7piDHii";
          };
          nbsp = ckie // {
            #password = # TODO
          };
        };
      };
    };
  };
}
