{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.cookie.services.pleroma;
  port = 17483;
  mail-util = pkgs.callPackage ../mailserver/util.nix { };
  svcEmail = (builtins.head
    (mail-util.process (fileContents ../../../secrets/email-salt)
      [ "pleroma/admin" ]));
in {
  options.cookie.services.pleroma = {
    enable = mkEnableOption "Enables pleroma service";
    host = mkOption {
      type = types.str;
      default = "fedi.ckie.dev";
      description = "the host";
    };
  };

  config = mkIf cfg.enable {
    cookie.secrets.pleroma = {
      source = "./secrets/pleroma.exs";
      dest = "${config.services.pleroma.stateDir}/secrets.exs";
      owner = "pleroma";
      group = "pleroma";
      permissions = "0400";
      wantedBy = "pleroma.service";
    };

    cookie.services.postgres = {
      enable = true;
      comb.pleroma = {
        networkTrusted = true;
        extraSql = ''
          ALTER DATABASE pleroma OWNER TO pleroma;
          --Extensions made by ecto.migrate that need superuser access
          CREATE EXTENSION IF NOT EXISTS citext;
          CREATE EXTENSION IF NOT EXISTS pg_trgm;
          CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
        '';
      };
    };

    services.pleroma = {
      enable = true;
      configs = singleton ''
        import Config

        config :pleroma, Pleroma.Web.Endpoint,
          url: [host: "${cfg.host}", scheme: "https", port: 443],
          http: [ip: {127, 0, 0, 1}, port: ${toString port}]

        config :pleroma, :instance,
          name: "cookies!!",
          email: "${svcEmail}",
          notify_email: "${svcEmail}",
          limit: 5000,
          registrations_open: false

        config :pleroma, :media_proxy,
          enabled: false,
          redirect_on_failure: true
          #base_url: "https://cache.pleroma.social"


        # Configure web push notifications
        config :web_push_encryption, :vapid_details,
          subject: "mailto:${svcEmail}"

        config :pleroma, Pleroma.Repo,
          adapter: Ecto.Adapters.Postgres,
          username: "pleroma",
          password: "",
          database: "pleroma",
          hostname: "localhost"

        config :pleroma, :database, rum_enabled: false
        config :pleroma, :instance, static_dir: "/var/lib/pleroma/static" # TODO
        config :pleroma, Pleroma.Uploaders.Local, uploads: "/var/lib/pleroma/uploads"
        config :pleroma, configurable_from_database: false
        config :pleroma, Pleroma.Upload, filters: [Pleroma.Upload.Filter.Exiftool]
      '';
      secretConfigFile = config.cookie.secrets.pleroma.dest;
    };

    systemd.services.pleroma.path = [ pkgs.exiftool ];

    cookie.services.nginx.enable = true;
    services.nginx = {
      virtualHosts."${cfg.host}" = {
        http2 = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString port}";
          recommendedProxySettings = false;
          extraConfig = ''
            etag on;
            gzip on;

            add_header 'Access-Control-Allow-Origin' '*' always;
            add_header 'Access-Control-Allow-Methods' 'POST, PUT, DELETE, GET, PATCH, OPTIONS' always;
            add_header 'Access-Control-Allow-Headers' 'Authorization, Content-Type, Idempotency-Key' always;
            add_header 'Access-Control-Expose-Headers' 'Link, X-RateLimit-Reset, X-RateLimit-Limit, X-RateLimit-Remaining, X-Request-Id' always;
            if ($request_method = OPTIONS) {
              return 204;
            }
            add_header X-XSS-Protection "1; mode=block";
            add_header X-Permitted-Cross-Domain-Policies none;
            add_header X-Frame-Options DENY;
            add_header X-Content-Type-Options nosniff;
            add_header Referrer-Policy same-origin;
            add_header X-Download-Options noopen;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            client_max_body_size 512m;
          '';
        };
        extraConfig = ''
          access_log /var/log/nginx/pleroma.access.log;
        '';
      };
    };

    cookie.services.prometheus.nginx-vhosts = [ "pleroma" ];
    cookie.restic.paths = [ "/var/lib/pleroma" ];
  };
}
