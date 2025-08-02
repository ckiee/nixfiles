{ lib, config, pkgs, ... }@margs:

let
  cfg = config.cookie.services.pupcat;
  util = import ../util.nix margs;
in with lib; {
  options.cookie.services.pupcat = {
    enable = mkEnableOption "the mei.puppycat.house service";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      services.nginx.virtualHosts."puppycat.house" = {
        redirectCode = 302;
        globalRedirect = "mei.puppycat.house";
      };

      cookie.services.websync.sites."mei.puppycat.house" = {
        enable = true;
        nginxOut = {
          locations."/" = {
            proxyPass = "http://127.0.0.1:32582";
          };

          extraConfig = ''
            access_log /var/log/nginx/pupcat.access.log;
          '';
        };

      };

      systemd.services.pupcat.serviceConfig = {
        ReadWritePaths = [ "/var/www/websync/mei.puppycat.house" ];
        SystemCallFilter = mkForce [ ];
      };

      cookie.services.stfed = {
        enable = true;
        # .stignore might nede to be placed manually on flowe, unsure..
        hooks = [{
          folder = "${config.cookie.user.home}/www/mei.puppycat.house";
          # file_down_sync_done: triggers when a file has been fully synchronized locally (see filter to match for a specific file)
          # folder_down_sync_done: triggers when a folder has been fully synchronized locally
          # file_conflict: triggers when Syncthing creates a .stconflict file due to a synchronization conflict
          event = "folder_down_sync_done";
          # glob rule for specific file matching for file_down_sync_done events
          # filter = "shopping-list.txt"
          command = pkgs.writeShellScript "ppcat-restart-cmd" ''
            set -euxo pipefail
            sleep 20
            /run/wrappers/bin/sudo systemctl restart pupcat
          '';
          allow_concurrent = false;
        }];
      };
    }

    {
      cookie.services.postgres = {
        enable = true;
        comb.pupcat = { ensureDBOwnership = true; };
      };
      systemd.services.pupcat.serviceConfig = {
        RemoveIPC = mkForce "false";
        ReadWritePaths = [ "/run/postgresql" ];
        RestrictAddressFamilies = mkForce [ ];
        ProtectHome =
          mkForce "false"; # needs to read ~pupcat/.config/git/config
      };
    }

    (util.mkService "pupcat" {
      description = "mei.puppycat.house";
      extraGroups = [ "websync" ];
      # secrets.config = {
      #   source = "./secrets/daiko.json";
      #   dest = "${cfg.folder}/config.json";
      #   permissions = "0400";
      # };
      path = with pkgs; [ bun nodejs git ];
      script = ''
        git config --global --replace-all safe.directory /var/www/websync/mei.puppycat.house
        cd /var/www/websync/mei.puppycat.house
        [ -e .env.prod ] &&
          set -a && source .env.prod && set +a

        HOST=127.0.0.1 PORT=32582 exec \
            bun ./www/index.js
      '';
    })
  ]);
}
