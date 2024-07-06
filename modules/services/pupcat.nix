{ lib, config, pkgs, ... }@margs:

let
  cfg = config.cookie.services.pupcat;
  util = import ./util.nix margs;
in with lib; {
  options.cookie.services.pupcat = {
    enable = mkEnableOption "the mei.puppycat.house service";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      cookie.services.websync.sites."mei.puppycat.house" = {
        enable = true;
        nginxOut.locations."/".proxyPass = "http://127.0.0.1:32582";
      };

      systemd.services.pupcat.serviceConfig = {
        ReadWritePaths = [ "/var/www/websync/mei.puppycat.house" ];
        SystemCallFilter = mkForce [ ];
      };

      cookie.services.stfed = {
        enable = true;
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
            sleep 5
            /run/wrappers/bin/sudo systemctl restart pupcat
          '';
          allow_concurrent = false;
        }];
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
      script = ''
        HOST=127.0.0.1 PORT=32582 ORIGIN=https://mei.puppycat.house exec \
            ${pkgs.bun}/bin/bun /var/www/websync/mei.puppycat.house/www/index.js
      '';
    })
  ]);
}
