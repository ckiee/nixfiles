{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.services.websync;
  home = config.cookie.user.home;
in with lib; {
  options.cookie.services.websync = {
    enable = mkEnableOption "websync /var/www + syncthing and nginx serves it";
  };

  config = mkMerge [
    {
      # there is an unfortunate indirection here: ~ckie/www/* -> /var/www
      # because our syncthing is first meant for home usage, not serving.
      cookie.services.syncthing.folders = {
        "mei.puppycat.house" = {
          path = "${home}/git/mei.puppycat.house";
          devices = [ "cookiemonster" "thonkcookie" "flowe" ];
        };
      };
    }

    (mkIf cfg.enable {
      services.nginx.virtualHosts = {
        "mei.puppycat.house".root = "/var/www/websync/mei.puppycat.house/www";
      };

      cookie.services.syncthing.folders."mei.puppycat.house".path =
        mkForce "${home}/www/mei.puppycat.house";

      systemd.services.websync-bindfs.preStart = mkBefore ''
        mkdir -p /var/www
      '';
      cookie.bindfs.websync = {
        source = "${home}/www";
        dest = "/var/www/websync";
        overlay = false;
        args =
          "--create-for-user=ckie --create-with-perms=0600 -u nginx -g nginx -p 0600,u+X";
        wantedBy = [ "nginx.service" ];
      };
    })
  ];
}
