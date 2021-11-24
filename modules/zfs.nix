{ lib, config, pkgs, ... }:

let cfg = config.cookie.zfs;

in with lib; {
  options.cookie.zfs = { enable = mkEnableOption "Enables ZFS management"; };

  config = mkIf cfg.enable {
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
  };
}
