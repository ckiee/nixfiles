{ lib, config, pkgs, ... }:

let cfg = config.cookie.zfs;

in with lib; {
  options.cookie.zfs = {
    enable = mkEnableOption "Enables ZFS management";
    manageZroot = mkOption {
      type = types.bool;
      default = config.fileSystems."/".fsType == "zfs";
      description = "Whether this machine should manage zroot";
    };
    arcMax = mkOption {
      type = types.float;
      default = 1;
      description = "Maixmum size of the in-memory ARC cache in gigs";
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      # This module works alongside the autoinstaller
      boot = {
        initrd.supportedFilesystems = [ "zfs" ];
        zfs = {
          forceImportRoot = false;
          devNodes = "/dev/disk/by-partlabel";
        };
      };

      networking.hostId = pkgs.lib.concatStringsSep "" (pkgs.lib.take 8
        (pkgs.lib.stringToCharacters
          (builtins.hashString "sha256" config.networking.hostName)));

      boot.kernelParams = ["zfs.zfs_arc_max=${toString (cfg.arcMax * 1.074e+9)}"];
    })

    (mkIf (cfg.manageZroot && cfg.enable) {
      services.zfs = {
        autoScrub = {
          enable = true;
          interval = "monthly";
          pools = [ "zroot" ];
        };
        # TODO let zfs send mail
      };
    })
  ];
}
