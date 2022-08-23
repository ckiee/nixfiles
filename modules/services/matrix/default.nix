{ sources, config, lib, pkgs, ... }:

let
  cfg = config.cookie.services.matrix;
in with lib; {
  imports = [ ./discord.nix ];

  options.cookie.services.matrix = {
    enable = mkEnableOption "Enables the Matrix service using Synapse";
    host = mkOption {
      type = types.str;
      default = "localhost";
      description = "The user-facing host";
      example = "ckie.dev";
    };
    serviceHost = mkOption {
      type = types.str;
      default = "matrix.localhost";
      description = "The reverse-proxied host";
      example = "matrix.ckie.dev";
    };
    elementRoot = mkOption {
      type = types.package;
      default = pkgs.callPackage ./web.nix { };
      readOnly = true;
      description = "The element-web we're serving";
    };
  };

  config = mkIf cfg.enable {
    ##
    ## reverse proxy..
    ##
    services.nginx.virtualHosts = {
      ${cfg.host} = {
        locations."/.well-known/matrix/server".extraConfig = let
          # use 443 instead of the default 8448 port to unite
          # the client-server and server-server port for simplicity
          server = { "m.server" = "${cfg.serviceHost}:443"; };
        in ''
          add_header Content-Type application/json;
          return 200 '${builtins.toJSON server}';
        '';
        locations."/.well-known/matrix/client".extraConfig = let
          client = {
            "m.homeserver" = { "base_url" = "https://${cfg.serviceHost}"; };
            "m.identity_server" = { "base_url" = "https://vector.im"; };
          };
          # ACAO required to allow element-web on any URL to request this json file
        in ''
          access_log /var/log/nginx/matrix.access.log;
          add_header Content-Type application/json;
          add_header Access-Control-Allow-Origin *;
          return 200 '${builtins.toJSON client}';
        '';
      };
      ${cfg.serviceHost} = {
        locations = {
          "/admin".root = "${pkgs.synapse-admin}";
          "/".root = "${cfg.elementRoot}";
        };
        # log for prom
        extraConfig = ''
          access_log /var/log/nginx/matrix.access.log;
        '';

        # forward all Matrix API calls to synapse
        locations."/_matrix".proxyPass =
          "http://[::1]:8008"; # without a trailing /
        locations."/_synapse".proxyPass = "http://[::1]:8008";
      };
    };
    cookie.services.prometheus.nginx-vhosts = [ "matrix" ];
    ##
    ## DAEMON
    ##

    cookie.services.postgres = {
      enable = true;
      comb.synapse = { };
    };

    # The homeserver's signing key
    cookie.secrets.matrix-signing-key = {
      source = "./secrets/matrix-signing-key";
      dest = "${config.services.matrix-synapse.dataDir}/homeserver.signing.key";
      owner = "matrix-synapse";
      group = "matrix-synapse";
      permissions = "0400";
    };

    # ...also, only start the homeserver up AFTER that key
    # has been decrypted.
    systemd.services.matrix-synapse = rec {
      requires = [ "matrix-signing-key-key.service" ];
      after = requires;
    };

    # Setup backups for the media; the rest is in Postgres which is backed up by it's
    # corresponding module.

    cookie.restic.paths = [ "${config.services.matrix-synapse.dataDir}/media" ];

    # The *actual* homeserver configuration

    services.matrix-synapse = {
      enable = true;
      package = pkgs.matrix-synapse;
      settings = {
        server_name = cfg.host;
        public_baseurl = "https://${cfg.serviceHost}/";
        database = {
          name = "psycopg2";
          args = {
            database = "synapse";
            user = "synapse";
          };
        };
        registration_shared_secret =
          fileContents ../../../secrets/matrix-synapse-registration;

        enable_registration = true;
        registration_requires_token = true;

        listeners = [{
          port = 8008;
          bind_addresses = singleton "::1";
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [{
            names = [ "client" "federation" ];
            compress = false;
          }];
        }];

        logConfig = ''
          version: 1

          # In systemd's journal, loglevel is implicitly stored, so let's omit it
          # from the message text.
          formatters:
              journal_fmt:
                  format: '%(name)s: [%(request)s] %(message)s'

          filters:
              context:
                  (): synapse.util.logcontext.LoggingContextFilter
                  request: ""

          handlers:
              journal:
                  class: systemd.journal.JournalHandler
                  formatter: journal_fmt
                  filters: [context]
                  SYSLOG_IDENTIFIER: synapse

          root:
              level: WARNING
              handlers: [journal]

          disable_existing_loggers: False
        '';
      };
    };
    # HACK: pr for nixpkgs
    systemd.services.matrix-synapse.serviceConfig = {
      LimitNPROC = 64;
      LimitNOFILE = 1048576;
      # It eats a lot of memory.
      Restart = mkForce "always";
      RuntimeMaxSec = "1d";
    };
  };
}
