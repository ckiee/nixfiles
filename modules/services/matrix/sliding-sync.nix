{ config, lib, pkgs, ... }:

with lib;

let cfg = config.cookie.services.matrix;
in {
  config = mkIf cfg.enable {
    # cookie.restic.paths = [ "/var/lib/matrix-synapse/discord" ];TODO

    # https://github.com/Mic92/dotfiles/blob/15aa29291b9a4d490e623d57a1605bb74c3210fc/nixos/eve/modules/dendrite.nix#L150
    services.matrix-synapse.sliding-sync = {
      enable = true;
      settings.SYNCV3_SERVER = "http://[::1]:8008";
      environmentFile = config.cookie.secrets.matrix-sliding-sync.dest;
    };

    cookie.secrets.matrix-sliding-sync = {
      source = "./secrets/matrix-sliding-sync.env";
      dest = "/var/run/matrix-sliding-sync.env";

      owner = "root";
      permissions = "0400";
      generateCommand = ''
        mv ./secrets/matrix-sliding-sync.env{,.bak} || true # should never happen, but I feel like it.
        echo SYNCV3_SECRET=$(${
          getBin pkgs.openssl
        }/bin/openssl rand -base64 32) > ./secrets/matrix-sliding-sync.env
      '';

      wantedBy = "matrix-sliding-sync.service";
    };

    cookie.services.matrix.clientWellKnown."org.matrix.msc3575.proxy".url =
      "https://${cfg.serviceHost}";

    # proactively copying this from all the other matrixy things..
    systemd.services.matrix-appservice-discord.serviceConfig = {
      # LimitNPROC = 64;
      # LimitNOFILE = 1048576;

      # It eats a lot of memory.
      Restart = mkForce "always";
      RuntimeMaxSec = "1d";
    };

    services.nginx.virtualHosts = {
      ${cfg.serviceHost} = {
        # sliding sync, from Mic92 again
        locations."~ ^/(client/|_matrix/client/unstable/org.matrix.msc3575/sync)" =
          {
            proxyPass =
              "http://${config.services.matrix-synapse.sliding-sync.settings.SYNCV3_BINDADDR}";
          };
      };
    };

  };
}
