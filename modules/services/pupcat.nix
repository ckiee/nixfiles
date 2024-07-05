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
        ReadWritePaths = [ "/var/www/websync/mei.puppycat.house/www" ];
        SystemCallFilter = mkForce [ ];
      };

      users.users.pupcat.extraGroups = [ "websync" ];
    }

    (util.mkService "pupcat" {
      description = "mei.puppycat.house";
      # secrets.config = {
      #   source = "./secrets/daiko.json";
      #   dest = "${cfg.folder}/config.json";
      #   permissions = "0400";
      # };
      script = ''
        HOST=127.0.0.1 PORT=32582 ORIGIN=https://mei.puppycat.house exec \
            ${pkgs.bun}/bin/bun /var/www/websync/mei.puppycat.house/www.stage/index.js
      '';
    })
  ]);
}
