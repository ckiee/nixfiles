{ config, lib, pkgs, ... }:

with lib;

let cfg = config.cookie.services.matrix;
in {
  imports = [ ./vendor.nix ];

  config = mkIf cfg.enable {
    # FIXME: Backup "/var/lib/matrix-hookshot"?
    # Cheers, MIT license https://github.com/etu/nixconfig/blob/50771a79e3c485290c4bf6113c5183b788877e0f/hosts/vps06/services/matrix.nix#L19

    services.nginx.virtualHosts.${cfg.serviceHost}.locations."~ ^/_hookshot/(.*)" =
      {
        proxyPass = "http://127.0.0.1:9582/$1";
        extraConfig = "proxy_set_header X-Forwarded-Ssl on;";
      };

    services.matrix-synapse.settings.app_service_config_files =
      [ "/var/lib/matrix-synapse/hookshot/registration.yaml" ];

    cookie.bindfs.matrix-hookshot = {
      source = "/var/lib/matrix-hookshot";
      dest = "/var/lib/matrix-synapse/hookshot";
      overlay = false;
      args = "-u matrix-synapse -g matrix-synapse -p 0400,u+D";
      wantedBy = [ "matrix-synapse.service" ];
    };

    services.matrix-hookshot = {
      enable = true;
      registration = {
        sender_localpart = "_hookshot_";
        namespaces = {
          users = [
            {
              exclusive = true;
              regex = "^@webhook_.*:${cfg.host}";
            }
            {
              exclusive = true;
              regex = "@_hookshot_:${cfg.host}";
            }
          ];
        };
      };
      config = {
        bridge.domain = cfg.host;
        bridge.url = "http://[::1]:8008"; # =>synapse
        bridge.mediaUrl = "https://${cfg.serviceHost}";

        logging.level = "info";

        generic.enabled = true;
        generic.urlPrefix = "https://${cfg.serviceHost}/_hookshot/webhook";
        generic.allowJsTransformationFunctions = false;
        generic.waitForComplete = false;
        generic.enableHttpGet = false;
        generic.userIdPrefix = "webhook_";

        permissions = [
          {
            actor = "@ckie:ckie.dev";
            services = [{
              service = "*";
              level = "admin";
            }];
          }
          {
            actor = "@lily:lily.flowers";
            services = [{
              service = "webhooks";
              level = "manageConnections";
            }];
          }
        ];

        listeners = [{
          port = 9582; # arbitrary port
          bindAddress = "127.0.0.1";
          resources = [ "webhooks" ];
        }];
      };
    };
  };
}
