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
      package = (pkgs.matrix-appservice-discord.override {
        inherit (pkgs.yarn2nix-moretea.override { nodejs = pkgs.nodejs_20; })
          mkYarnPackage;
      }).overrideAttrs (prev: {
        patches = (prev.patches or [ ]) ++ [
          ./pr_878.patch # Request from @lea:m.lea.moe: https://github.com/matrix-org/matrix-appservice-discord/pull/878
        ];

        doCheck =
          false; # tests are flaky on slow aarch64-linux, since they're time-dependent..
      });
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

    cookie.restic.paths = [ "/var/lib/matrix-synapse/discord" ];

    cookie.bindfs.matrix-appservice-discord = {
      source = "/var/lib/matrix-appservice-discord";
      dest = "/var/lib/matrix-synapse/discord";
      overlay = false;
      args = "-u matrix-synapse -g matrix-synapse -p 0400,u+D";
      wantedBy = [ "matrix-synapse.service" ];
    };

    # this is copied from synapse because this piece of junk[1] also
    # started taking up too much memory. i hope they fix it.
    #
    # [1] a toucher of this codebase says it is awful so i'm taking that as permission
    #     to call it junk!
    #
    systemd.services.matrix-appservice-discord.serviceConfig = {
      LimitNPROC = 64;
      LimitNOFILE = 1048576;
      # It eats a lot of memory.
      Restart = mkForce "always";
      RuntimeMaxSec = "1d";
    };
  };
}
