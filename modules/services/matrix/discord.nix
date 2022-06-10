{ config, lib, pkgs, ... }:

with lib;

let cfg = config.cookie.services.matrix;
in {
  config = mkIf cfg.enable {
    cookie.secrets.matrix-appservice-discord = {
      source = "./secrets/matrix-appservice-discord.env";
      dest = "/var/run/matrix-appservice-discord.env";
      owner = "root";
      group = "root";
      permissions = "0400";
    };

    services.matrix-appservice-discord = {
      enable = true;
      serviceDependencies = [ "matrix-synapse.service" ];
      environmentFile = /.
        + config.cookie.secrets.matrix-appservice-discord.dest;
      settings.bridge = {
        domain = cfg.host;
        homeserverUrl = "https://${cfg.serviceHost}";
        adminMxid = "@ckie:ckie.dev";
        enableSelfServiceBridging = true;
      };
    };

    services.matrix-synapse.settings.app_service_config_files =
      [ "/var/lib/matrix-synapse/discord/discord-registration.yaml" ];

    cookie.bindfs.matrix-appservice-discord = {
      source = "/var/lib/matrix-appservice-discord";
      dest = "/var/lib/matrix-synapse/discord";
      overlay = false;
      args = "-u matrix-synapse -g matrix-synapse -p 0400,u+D";
      wantedBy = [ "matrix-synapse.service" ];
    };
  };
}
