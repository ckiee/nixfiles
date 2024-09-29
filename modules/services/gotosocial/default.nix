{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.gotosocial;

in with lib; {
  options.cookie.services.gotosocial = {
    enable = mkEnableOption "gts";
    host = mkOption {
      type = types.str;
      default = "league.puppycat.house";
    };
  };

  config = mkIf cfg.enable {
    cookie.services = {
      nginx.enable = true;
      postgres.enable = true;
    };

    services.gotosocial = {
      enable = true;
      setupPostgresqlDB = true; # backups fall under postgres now
      settings = {
        host = "league.puppycat.house";
        protocol = "https";
        bind-address = "127.0.0.1";
        port = 28439;

        instance-federation-mode = "allowlist";
        instance-inject-mastodon-version = true;
        instance-languages = [ "en" ];

        # If this is a single user instance, you can change this to your user
        # and it'll go to your profile when browsing to your instance domain.
        landing-page-user = "mei";
        accounts-registration-open = false;
        accounts-allow-custom-css = true;
        statuses-max-chars = 50000;
      };
    };

    services.nginx.virtualHosts = with config.services.gotosocial.settings; {
      "${host}" = {
        forceSSL = true;
        locations = {
          "/" = {
            recommendedProxySettings = true;
            proxyWebsockets = true;
            proxyPass = "http://localhost:28439";
          };
        };
      };
    };

  };
}
