{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.cookie.services.websync;
  home = config.cookie.user.home;
  enabledSites = filterAttrs (_: { enable, ... }: enable) cfg.sites;
in {
  options.cookie.services.websync = {
    enable = mkEnableOption "websync /var/www + syncthing and nginx serves it";
    sites = mkOption {
      description = "Sites for websync to configure";
      type = types.attrsOf (types.submodule ({ name, ... }: {
        options = {
          enable = mkEnableOption "this websync setup";
          fsName = mkOption {
            description = "filesystem-safe name";
            type = types.str;
            default = replaceStrings [ "/" ] [ "_" ] name;
          };
        };
      }));
      default = {
        # don't forget to also add to cookiemonster's restic.paths
        "mei.puppycat.house".enable = true;
        "bwah.ing".enable = true;
      };
    };
  };

  config = mkMerge [
    {
      # there is an unfortunate indirection here: ~ckie/www/* -> /var/www
      # because our syncthing is first meant for home usage, not serving.
      cookie.services.syncthing.folders = mapAttrs (name:
        { fsName, ... }: {
          path = "${home}/git/${fsName}";
          devices = [ "cookiemonster" "thonkcookie" "flowe" ];
        }) enabledSites;
    }

    (mkIf cfg.enable {
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

      # per-site..
      #
      services.nginx.virtualHosts = mapAttrs
        (name: { fsName, ... }: { root = "/var/www/websync/${fsName}/www"; })
        enabledSites;

      cookie.services.syncthing.folders = mapAttrs
        (name: { fsName, ... }: { path = mkForce "${home}/www/${fsName}"; })
        enabledSites;
    })

    # one-offs...
    (mkIf cfg.enable {
      services.nginx.virtualHosts."bwah.ing" = {
        serverName = "bwah.ing *.bwah.ing";
        # forceSSL disabled on non-critical website using HSTS preloaded TLD.
        addSSL = true;
        useACMEHost = "bwah.ing";
      };
    })

  ];
}
