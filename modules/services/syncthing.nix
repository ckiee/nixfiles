{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.syncthing;

in with lib; {
  options.cookie.services.syncthing = {
    enable = mkEnableOption "Enables Syncthing file syncing";
  };

  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      user = "ckie";
      dataDir = config.cookie.user.home;
      # This mapAttrs variant only changes V, not KV. Do not be fooled (:
      declarative = {
        overrideDevices = true;
        overrideFolders = true;

        # see /ext/metadata.toml
        devices = let
          trackedHosts = mapAttrs (name: host: {
            id = host.syncthing_id;
            inherit name;
          }) (filterAttrs
            (name: host: host ? syncthing_id) # host.syncthing_id = null | str
            config.cookie.metadata.raw.hosts);
          untrackedHosts = {
            phone = {
              id =
                "5UBCVLJ-TV7IVNG-CFTXONW-Z7YUSPJ-QCQSJC4-6T2BTAB-5BNNCD4-HETZSA7";
            };
          };
        in untrackedHosts // trackedHosts;


        folders = let home = config.cookie.user.home;
        in {
          "nixfiles" = {
            path = "${home}/git/nixfiles";
            devices = [ "cookiemonster" "thonkcookie" ];
          };

          "sync" = {
            path = "${home}/Sync";
            devices = [ "cookiemonster" "thonkcookie" ];
          };

          "ssh" = {
            path = "${home}/.ssh";
            devices = [ "cookiemonster" "thonkcookie" ];
            versioning = {
              type = "simple";
              params.keep =
                "50"; # keep 50 old versions of files around. should be fine considering keys are quite small.
            };
          };

          "music" = {
            id = "3ffxr-fpjwy"; # to keep compat with existing phone
            path = "${home}/Music";
            devices = [ "cookiemonster" "thonkcookie" "phone" ];
          };
        };
      };
    };
  };
}
