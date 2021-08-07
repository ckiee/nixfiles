{ config, lib, pkgs, ... }:

with lib;

let cfg = config.cookie.services.matrix;
in {
  config = mkIf cfg.enable {

    cookie.secrets.matrix-appservice-discord = {
      source = ../../../secrets/matrix-appservice-discord.env;
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
      };
    };

    services.matrix-synapse.app_service_config_files =
      [ "/var/lib/matrix-synapse/discord/discord-registration.yaml" ];

    systemd.services.matrix-discord-perms = {
      description = "Setup bindfs for /var/lib/matrix-synapse/discord";
      wantedBy = [ "matrix-synapse.service" ];
      serviceConfig.Type = "forking";

      preStart =
        "${pkgs.coreutils}/bin/mkdir /var/lib/matrix-synapse/discord || true";
      script =
        "${pkgs.bindfs}/bin/bindfs -u matrix-synapse -g matrix-synapse -p 0400,u+X /var/lib/matrix-appservice-discord /var/lib/matrix-synapse/discord";
    };
  };
}
