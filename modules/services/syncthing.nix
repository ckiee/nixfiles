{ nodes, lib, config, pkgs, options, ... }:

let cfg = config.cookie.services.syncthing;

in with lib; {
  options.cookie.services.syncthing = {
    enable = mkEnableOption "Enables Syncthing file syncing";
    runtimeId = mkOption {
      type = types.nullOr types.str;
      description = "the ID given to this machine at runtime";
      default = null;
    };
    folders = mkOption {
      # fuck. kdsfjdsfkjdf this is so complicated but hey it works i think
      type = (options.services.syncthing.settings.type.getSubOptions
        [ ]).folders.type;
      description =
        ".folders but they only turn on when it's relevant for the host";
    };
  };

  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      user = "ckie";
      dataDir = config.cookie.user.home;
      # This mapAttrs variant only changes V, not KV. Do not be fooled (:

      overrideDevices = true;
      overrideFolders = true;

      settings = {
        devices = let
          trackedHosts = mapAttrs (host: hostConfig: {
            id = hostConfig.config.cookie.services.syncthing.runtimeId;
            name = host;
          }) (filterAttrs (host: hostConfig:
            hostConfig.config.cookie.services.syncthing.runtimeId != null)
            nodes);
          untrackedHosts = {
            samsung.id =
                "5UBCVLJ-TV7IVNG-CFTXONW-Z7YUSPJ-QCQSJC4-6T2BTAB-5BNNCD4-HETZSA7";
            iphone.id =
              "CMBSN7P-6N4B6ZL-YTNSLNE-C2O4UM3-32AV7G4-TL2KYUI-55WWSRL-HVRGHQ3";
          };
        in untrackedHosts // trackedHosts;

        folders = filterAttrs
          (_: folder: any (d: config.networking.hostName == d) folder.devices)
          config.cookie.services.syncthing.folders;
      };
    };

    cookie.services.syncthing.folders = let home = config.cookie.user.home;
    in {
      "nixfiles" = {
        path = "${home}/git/nixfiles";
        devices = [ "cookiemonster" "thonkcookie" "pansear" ];
        versioning = { # for the secrets
          type = "simple";
          params.keep = "10";
        };
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
        devices = [ "cookiemonster" "thonkcookie" "samsung" ];
      };

      "dcim" = {
        path = "${home}/DCIM";
        devices = [ "cookiemonster" "thonkcookie" "samsung" ];
      };

      # transqsh in ./transqsh.nix

      # it TURNS out it really doesn't like it when you do this.. for some reason the filenames incl the machine hostname
      # "mail" = {
      #   path = "${home}/Mail";
      #   devices = [ "cookiemonster" "thonkcookie" ];
      #   versioning = {
      #     type = "trashcan";
      #     params.cleanoutDays = "0"; # never. we can clean it up manually if needed, but this should be mostly write-only.
      #   };
      # };
    };
  };
}
