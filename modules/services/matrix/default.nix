{ sources, config, lib, pkgs, ... }:

let cfg = config.cookie.services.matrix;
in with lib; {
  imports = [ ./discord.nix ./janitor.nix ];

  options.cookie.services.matrix = {
    enable = mkEnableOption "Matrix service using Synapse";
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
    clientWellKnown = mkOption {
      type = (pkgs.formats.json { }).type;
      description = "JSON served on /.well-known/matrix/client";
    };
  };

  config = mkIf cfg.enable {
    ##
    ## reverse proxy..
    ##

    cookie.services.matrix.clientWellKnown = {
      "m.homeserver".base_url = "https://${cfg.serviceHost}";
      "m.identity_server".base_url = "https://vector.im";
    };

    services.nginx.virtualHosts = {
      ${cfg.host} = {
        locations."= /.well-known/matrix/server".extraConfig = let
          # use 443 instead of the default 8008 port to unite
          # the client-server and server-server port for simplicity
          server = { "m.server" = "${cfg.serviceHost}:443"; };
        in ''
          add_header Content-Type application/json;
          return 200 '${builtins.toJSON server}';
        '';
        locations."= /.well-known/matrix/client".extraConfig =
          # ACAO required to allow element-web on any URL to request this json file
          ''
            access_log /var/log/nginx/matrix.access.log;
            add_header Content-Type application/json;
            add_header Access-Control-Allow-Origin *;
            return 200 '${builtins.toJSON cfg.clientWellKnown}';
          '';
      };
      ${cfg.serviceHost} = {
        locations = {
          "/admin".root = pkgs.linkFarm "synapse-admin-routing" [{
            name = "admin";
            path = "${pkgs.synapse-admin}";
          }];
          "/".root = "${cfg.elementRoot}";
        };
        # log for prom
        extraConfig = ''
          access_log /var/log/nginx/matrix.access.log;
        '';

        # forward all Matrix API calls to synapse
        locations."/_matrix" = {
          proxyPass = "http://[::1]:8008"; # without a trailing /
          extraConfig = ''
            proxy_send_timeout 100;
          '';
        };
        locations."/_synapse".proxyPass = "http://[::1]:8008";
      };
    };
    cookie.services.prometheus.nginx-vhosts = [ "matrix" ];
    ##
    ## DAEMON
    ##

    cookie.services.postgres = {
      enable = true;
      comb.synapse = {
        networkTrusted =
          true; # FIXME: Really really don't like this but the janitor doesn't actually support UNIX sockets unlike what it says..
        autoCreate = false;
        initSql = ''
          CREATE DATABASE "synapse" WITH
            TEMPLATE template0
            ENCODING = "UTF8"
            LC_COLLATE = "C"
            LC_CTYPE = "C";
        '';
      };
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

    # Setup backups for the media; the rest is in Postgres which is backed up by its
    # corresponding module.

    cookie.restic.paths = [ "${config.services.matrix-synapse.dataDir}/media" ];

    ## There's a few secret tokens we want to keep out of the Synapse config in
    ## the store..

    # A_: gen has to run before matrix-secret-config, try to help it along..
    cookie.secrets.A_matrix-smtp-password = rec {
      source = "./secrets/matrix-smtp-password";
      generateCommand = "mkRng > ${source}";
      runtime = false; # should never leave the deploying machine..
    };

    cookie.secrets.matrix-smtp-password-hash = rec {
      source = "./secrets/matrix-smtp-password-hash";
      generateCommand =
        "${pkgs.mkpasswd}/bin/mkpasswd -sm bcrypt < ${config.cookie.secrets.A_matrix-smtp-password.source} > ${source}";
      permissions = "0400"; # for the mailserver, not synapse..
    };

    mailserver.loginAccounts."matrixbot@ckie.dev" = {
      hashedPasswordFile = config.cookie.secrets.matrix-smtp-password-hash.dest;
      sendOnly = true;
    };

    cookie.secrets.matrix-secret-config = rec {
      source = "./secrets/matrix-secret-config.json";
      dest = "${config.services.matrix-synapse.dataDir}/secret-config.json";
      owner = "matrix-synapse";
      group = "matrix-synapse";
      permissions = "0440";
      generateCommand = ''
        nix-instantiate --eval ${
          ./make-secret-config.nix
        } --argstr root "$(pwd)" |& rg '^trace: (.+)' --replace '$1' > ${source}'';
      wantedBy = "matrix-synapse.service";
    };

    # The *actual* homeserver configuration

    services.matrix-synapse = {
      enable = true;
      extraConfigFiles =
        singleton config.cookie.secrets.matrix-secret-config.dest;
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

        enable_registration = true;
        registration_requires_token = true;

        redaction_retention_period = "3d";

        # there's also a "local_media_lifetime"; not using, should be inf. (not guaranteed though!)
        media_retention.remote_media_lifetime = "30d";

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

        # TODO: this shit took me hours to get right with the secret setup
        # and it's /still/ not working.. it finally accepts the config, but
        # for some reason the server responds 500 because of the smtp
        # submission.
        email = {
          notif_from = "matrix bot <matrixbot@ckie.dev>";
          smtp_host = assert config.cookie.services.mailserver.enable;
            "localhost";
          smtp_port = 587;
          force_tls = true;
          smtp_user = "matrixbot";
          # smtp_pass is in secret config
        };

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
